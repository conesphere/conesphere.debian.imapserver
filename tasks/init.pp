class dovecot (
	$ssl_key="/etc/letsencrypt/live/${fqdn}/privkey.pem",
	$ssl_cert="/etc/letsencrypt/live/${fqdn}/cert.pem",
	$ssl_ca="/etc/letsencrypt/live/${fqdn}/fullchain.pem",
	$port="993",
	$sieve=true,
) {
	unless defined(Package['dovecot-imapd']) { 
		package{'dovecot-imapd': 
			ensure=>'latest',
		}
	}
	unless defined(Package['dovecot-antispam']) { 
		package{'dovecot-antispam': 
			ensure=>'latest',
		}
	}
	unless defined(Package['dovecot-sieve']) { 
		package{'dovecot-sieve': 
			ensure=>'latest',
		}
	}
	unless defined(Package['dovecot-managesieved']) { 
		package{'dovecot-managesieved': 
			ensure=>'latest',
		}
	}
	unless defined(Package['dovecot-lmtpd']) { 
		package{'dovecot-lmtpd': 
			ensure=>'latest',
		}
	}
	unless defined(Class['stunnel']) { 
		class{'stunnel': }
	}
	$packages=["dovecot-imapd", "dovecot-antispam", "dovecot-sieve", "dovecot-lmtpd", "dovecot-managesieved"]
	$cpath="/etc/dovecot/conf.d"
	file{"${cpath}/10-logging.conf":
		source=>"puppet:///modules/dovecot/10-logging.conf",
		owner=>"root",
		group=>"root",
		mode=>"644",
		require=>Package[$packages],
	}
	file{"${cpath}/10-mail.conf":
		source=>"puppet:///modules/dovecot/10-mail.conf",
		owner=>"root",
		group=>"root",
		mode=>"644",
		require=>Package[$packages],
	}
	file{"${cpath}/20-imap.conf":
		content=>template("dovecot/20-imap.conf.erb"),
		owner=>"root",
		group=>"root",
		mode=>"644",
		require=>Package[$packages],
	}
	file{"${cpath}/10-master.conf":
		content=>template("dovecot/10-master.conf.erb"),
		owner=>"root",
		group=>"root",
		mode=>"644",
		require=>Package[$packages],
	}
	file{"${cpath}/10-ssl.conf":
		content=>template("dovecot/10-ssl.conf.erb"),
		owner=>"root",
		group=>"root",
		mode=>"644",
		require=>Package[$packages],
	}
	file{"${cpath}/20-lmtp.conf":
		content=>template("dovecot/20-lmtp.conf.erb"),
		owner=>"root",
		group=>"root",
		mode=>"644",
		require=>Package[$packages],
	}
	file{"/usr/bin/dovecot_archive.pl":
		owner=>"root",
		group=>"root",
		mode=>"755",
		source=>"puppet:///modules/dovecot/dovecot_archive.pl",
		require=>Package[$packages],
	}
	$files=["${cpath}/10-logging.conf","${cpath}/20-imap.conf", "${cpath}/10-mail.conf", "${cpath}/10-master.conf", "${cpath}/10-ssl.conf", "${cpath}/20-lmtp.conf"]
	service{"dovecot": 
		ensure=>"running",
		subscribe=>File[$files],
	}
	stunnel::link{"lmtps":
		client=>false,
		accept=>":::2525",
		connect=>"localhost:2526",
		key=>$ssl_key,
		cert=>$ssl_cert,
	}	
}
