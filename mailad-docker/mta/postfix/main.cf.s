# See /usr/share/postfix/main.cf.dist for a commented, more complete version

# Banner de bienvenida
smtpd_banner = $myhostname ESMTP

# No annadir el dominio, eso es trabajo del cliente
append_dot_mydomain = no

# Generar emails de "Su mensaje no ha podido ser entregado en X Horas,
#  lo seguiremos intentando" cada 4 horas
delay_warning_time = 4h

# Alias del email local no usar este para el dominio principal
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases

# mi nombre de pc y dominio, solo el local
# para el dominio real ver el virtual debajo
myhostname = _HOSTNAME_
mydomain = $myhostname

# mis destinos/origen del email local, no tocar
mydestination = $myhostname, localhost.$mydomain, localhost
myorigin = $myhostname

# host a quien debo entragarle el email para la salida hacia el exterior
# si estas directo a internet debes dejarlo en blanco
# Si es un IP se debe poner entre [1.2.3.4] para que postfix sepa
# que es IP y no haga consulta DNS
relayhost = _RELAY_

# mi red, por seguridad mi red soy yo y los servers de la DMZ
mynetworks = 127.0.0.0/8, _AMAVISIP_

# solo usaremos IPv4
inet_protocols = ipv4

# en que interfaces de red debo escuchar (todas IPv4)
inet_interfaces = all

# parametros generales 
recipient_delimiter = +
biff = no
home_mailbox = Maildir/
readme_directory = /usr/share/doc/postfix
html_directory = /usr/share/doc/postfix/html

# Tamanno de los mensajes estos dos parametros estan en bytes:
# o sea es: 1024 * 1024 * MB * 1.08 (8% por cabeceras)
# por defecto 2MB+
message_size_limit = _MESSAGESIZE_

# tamanno del buzon local, si limites, se gestiona por otro lado (dovecot)
mailbox_size_limit = 0

# filtro de contenido de amavisd
# OJO en los upgrades a amavis le encanta resetar esto y poner
content_filter = smtp-amavis:_AMAVISHN_:10024

# SASL con dovecot
smtpd_sasl_type = dovecot
smtpd_sasl_path = inet:mda:12345

# SALS cosas comunes
smtpd_sasl_auth_enable = yes
smtpd_sasl_authenticated_header = yes
smtpd_sasl_security_options = noanonymous
broken_sasl_auth_clients = yes

# TLS
smtpd_tls_cert_file = /certs/mail.crt
smtpd_tls_key_file = /certs/mail.key
smtpd_tls_CAfile = 
smtp_tls_security_level = may
smtpd_tls_security_level = may
smtpd_sasl_tls_security_options = $smtpd_sasl_security_options
smtpd_tls_auth_only = yes
smtp_tls_loglevel = 1
smtpd_tls_loglevel = 1
# Proteccion contra atake LogJam, FREAK & POODLE
smtpd_tls_eecdh_grade = strong
smtpd_tls_ciphers = high
smtpd_tls_mandatory_protocols = !SSLv2,!SSLv3,!TLSv1,!TLSv1.1
smtpd_tls_protocols = !SSLv2,!SSLv3,!TLSv1,!TLSv1.1
smtp_tls_mandatory_protocols = !SSLv2,!SSLv3,!TLSv1,!TLSv1.1
smtp_tls_protocols = !SSLv2,!SSLv3,!TLSv1,!TLSv1.1
smtpd_tls_exclude_ciphers = aNULL, eNULL, EXPORT, DES, RC4, MD5, PSK, aECDH, EDH-DSS-DES-CBC3-SHA, EDH-RSA-DES-CBC3-SHA, KRB5-DES, CBC3-SHA
smtpd_tls_dh1024_param_file = /certs/RSA2048.pem

###### EHLO RESTRICTION
# Requerir ehlo/helo
smtpd_helo_required = yes
smtpd_helo_restrictions =
    permit_mynetworks
    reject_invalid_helo_hostname
# estas estan desactivadas ya que solo funcionan sobre host de internet
# Solo se debe activar entre pasarelas o transportes de cara a internet
#    reject_unknown_hostname
#    reject_non_fqdn_hostname


##### CLIENT RESTRICTIONS
# rechazar pipelining y demorar 1 segundo, esto es un honeypot efectivo
# para los spammers, una vez que el cliente tiene la cabecera el spammer
# intentara meter todo el email de carretilla, esto demora 1 segundo la
# respuesta acentuando el efecto carretilla y luego... te rechazo si
# me lo tiras de carretilla, genial... sencillamente genial...
#smtpd_client_restrictions = sleep 1, reject_unauth_pipelining
#smtpd_delay_reject = no

# mapeos de los logins de los users contra su cuenta de correo
# para que usuario1@ no pueda mandar email como usuario2@
smtpd_sender_login_maps = ldap:/etc/postfix/ldap/email2user.cf

# para que el server sepa las direcciones locales validas y rechace las otras
# que parecen validas pero no existen
relay_recipient_maps = ldap:/etc/postfix/ldap/email2user.cf

# parametros del server...
smtpd_error_sleep_time = 1s
smtpd_soft_error_limit = 60
smtpd_hard_error_limit = 10

# por seguridad, para que el server no exponga los usuarios validos
disable_vrfy_command = yes

# filtro del cuerpo y cabeceras
header_checks = regexp:/etc/postfix/rules/header_checks
body_checks = regexp:/etc/postfix/rules/body_checks

# Declaracion de las Clases de restricciones nacionales
smtpd_restriction_classes =
    mail_national_in, mail_national_out,
    mail_local_in, mail_local_out,
    everyone_list,

## NACIONAL
# si el destino no es .cu rechazo
mail_national_in = check_sender_access regexp:/etc/postfix/rules/filter_nat
mail_national_out = check_recipient_access regexp:/etc/postfix/rules/filter_nat

## LOCAL
mail_local_in = check_sender_access regexp:/etc/postfix/rules/filter_loc
mail_local_out = check_recipient_access regexp:/etc/postfix/rules/filter_loc

## Everyone
everyone_list = check_sender_access regexp:/etc/postfix/rules/filter_loc

#### POSTSCREEN filtering on port 25
# By default postscreen withelist the mynetworks net.
postscreen_access_list = permit_mynetworks
# action for bad servers in blacklist
postscreen_blacklist_action = drop
# if new lines, bad dog!
postscreen_bare_newline_action = drop
# disable verify
postscreen_disable_vrfy_command = yes
# enforce the greet action
postscreen_greet_action = drop
# no pipelining
postscreen_pipelining_action = drop
# no auth in SMTP(25)
postscreen_command_filter = pcre:/etc/postfix/rules/command_filter.pcre
# DNSRBL in postscreen
postscreen_dnsbl_threshold = 3
postscreen_dnsbl_action = enforce
postscreen_dnsbl_sites = _DNSBL_LIST_

# restricciones del que envia
smtpd_sender_restrictions =
    # tengo que dejar permit mynetworks arriba, porque ahora permit soy yo
    # si no, no pinchan amavis, postgrey, etc...
    permit_mynetworks

    # FUERZA que el user que hace LOGIN sea el mismo del FROM, sino REJECT
    reject_unauthenticated_sender_login_mismatch
    reject_sender_login_mismatch

    # Impide enviar desde un dominio que no existe, ojo! si el DNS da bateo
    # este email sera rechazado como dominio no valido, !!!!!!!!!!!
    # desactivado por problemas de que se pierden email por DNS mal configurados
    #reject_unknown_sender_domain

    # aplicación nacional
    check_recipient_access ldap:/etc/postfix/ldap/national_in.cf
    check_sender_access ldap:/etc/postfix/ldap/national_out.cf

    # aplicación nacional
    check_recipient_access ldap:/etc/postfix/ldap/local_in.cf
    check_sender_access ldap:/etc/postfix/ldap/local_out.cf

    # chequeo de lista negra
    check_sender_access hash:/etc/postfix/rules/lista_negra

    # check everyone list protection
    check_recipient_access hash:/etc/postfix/rules/everyone_list_check

    # Permite solo envios con LOGIN
    permit_sasl_authenticated


# Restricciones de destinatarios
smtpd_recipient_restrictions =
    # politicas de buzón de correos (quota devecot)
    check_policy_service inet:mda:12340

    # check spf settings
    check_policy_service unix:private/policy-spf

    # tengo que dejar permit mynetworks arriba, porque ahora permit soy yo
    permit_mynetworks

    # rechazar si el destinatario no es un destino RFC compatible
    reject_non_fqdn_recipient

    # no recibir email para dominios que no existan y se pergunta al DNS
    # si confias en el DNS y no te preocupa perder correos de dominios
    # cubanos mal configurados descomenta esto
    #reject_unknown_recipient_domain

    # rechazar si no esta en la lista de usuarios validos
    reject_unlisted_recipient

    # rechazar si no es para mi destino cuando viene de afuera
    reject_unauth_destination

    # Permite si se ha autenticado y haz llegado hasta aqui
    permit_sasl_authenticated

# COPIA DE SEGURIDAD
# !!! OJO debes crear el user y ponerle un email valido en el AD!!!
always_bcc = _ALWAYSBCC_

# evitar la doble copia del always_bcc
receive_override_options = no_address_mappings

# Debug para diagnosticos sobre esta IP...
# revisar /var/log/mail.log, recuerda desactivarlo al final
#debug_peer_list = 10.0.3.161
#debug_peer_level = 16

# declaracion del dominio virtual...
virtual_mailbox_domains = _DOMAIN_
virtual_mailbox_maps = ldap:/etc/postfix/ldap/mailbox_maps.cf
virtual_alias_maps = hash:/etc/postfix/aliases/alias_virtuales, hash:/etc/postfix/aliases/auto_aliases
virtual_mailbox_base = /home/vmail
virtual_minimum_uid = 100
virtual_uid_maps = static:5000
virtual_gid_maps = static:5000
virtual_transport = lmtp:inet:mda:24

# para que se entreguen a dovecot como transport uno a uno
dovecot_destination_recipient_limit = 1
dovecot_destination_concurrency_limit = 1

# para forzar que los users sean los que existen y no otros
# depende de virtual_mailbox_maps para el chequeo.
smtpd_reject_unlisted_recipient = yes

# autenticacion de SMTP como cliente
# esto es requerido en etecsa y en muchos otro lugares sin internet directo
# que necesitan autenticarse para entregar a una relayhost
# ver comentarios en el fichero /etc/postfix/sasl_passwd
#smtp_sasl_auth_enable = yes
#smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd

# Compatibilidad con versiones modernas 
compatibility_level = 2

# plantillas para los reportes en espannol, tiio esto es la oostia, rediez!
bounce_template_file = /etc/postfix/bounce.cf

# docker, logging to stdout, see also postlog on master.cf
maillog_file = /dev/stdout
maillog_file_prefixes = /var, /dev, /tmp
