#!/bin/bash

# Variables
LAM_CONFIG_DIR="/var/lib/ldap-account-manager/config"
LDAP_BASE="dc=amsa,dc=udl,dc=cat"
PASSWORD=$1
HASH=$(slappasswd -h "{SSHA512}" -s "$PASSWORD" -o module-load=pw-sha2.la -o module-path=/usr/local/libexec/openldap)

# Eliminamos archivos existentes de configuración (si existen)
sudo rm -f $LAM_CONFIG_DIR/config.cfg
sudo rm -f $LAM_CONFIG_DIR/lam.conf

# Creamos config.cfg
sudo bash -c "cat > $LAM_CONFIG_DIR/config.cfg << EOL
{
    \"password\": \"$HASH\",
    \"default\": \"lam\",
    \"sessionTimeout\": \"30\",
    \"hideLoginErrorDetails\": \"false\",
    \"logLevel\": \"4\",
    \"logDestination\": \"SYSLOG\",
    \"allowedHosts\": \"\",
    \"passwordMinLength\": \"10\",
    \"passwordMinUpper\": \"0\",
    \"passwordMinLower\": \"0\",
    \"passwordMinNumeric\": \"0\",
    \"passwordMinClasses\": \"0\",
    \"passwordMinSymbol\": \"0\",
    \"checkedRulesCount\": \"-1\",
    \"passwordMustNotContainUser\": \"false\",
    \"passwordMustNotContain3Chars\": \"false\",
    \"externalPwdCheckUrl\": \"\",
    \"errorReporting\": \"default\",
    \"allowedHostsSelfService\": \"\",
    \"license\": \"\",
    \"licenseEmailFrom\": \"\",
    \"licenseEmailTo\": \"\",
    \"licenseWarningType\": \"all\",
    \"licenseEmailDateSent\": \"\",
    \"mailServer\": \"\",
    \"mailUser\": \"\",
    \"mailPassword\": \"\",
    \"mailEncryption\": \"TLS\",
    \"mailAttribute\": \"mail\",
    \"mailBackupAttribute\": \"passwordselfresetbackupmail\",
    \"configDatabaseType\": \"files\",
    \"configDatabaseServer\": \"\",
    \"configDatabasePort\": \"\",
    \"configDatabaseName\": \"\",
    \"configDatabaseUser\": \"\",
    \"configDatabasePassword\": \"\",
    \"moduleSettings\": \"eyJyZXF1ZXN0QWNjZXNzIjp7Imhpc3RvcnlSZXRlbnRpb25QZXJpb2QiOiIzNjUwIiwiZXhwaXJhdGlvblBlcmlvZCI6IjMwIn19\"
}
EOL"

# Creamos lam.conf
sudo bash -c "cat > $LAM_CONFIG_DIR/lam.conf << EOL
{
    \"ServerURL\": \"ldap://localhost:389\",
    \"useTLS\": \"no\",
    \"followReferrals\": \"false\",
    \"pagedResults\": \"false\",
    \"Passwd\": \"$HASH\",
    \"Admins\": \"cn=osproxy,ou=system,$LDAP_BASE\",
    \"defaultLanguage\": \"en_GB.utf8\",
    \"scriptPath\": \"\",
    \"scriptServer\": \"\",
    \"scriptRights\": \"750\",
    \"serverDisplayName\": \"\",
    \"activeTypes\": \"user,group\",
    \"accessLevel\": \"100\",
    \"loginMethod\": \"list\",
    \"loginSearchSuffix\": \"$LDAP_BASE\",
    \"loginSearchFilter\": \"uid=%USER%\",
    \"searchLimit\": \"0\",
    \"lamProMailFrom\": \"noreply@example.com\",
    \"lamProMailReplyTo\": \"\",
    \"lamProMailSubject\": \"Your password was reset\",
    \"lamProMailText\": \"Dear @@givenName@@ @@sn@@,+::++::+your password was reset to: @@newPassword@@+::++::++::+Best regards+::++::+deskside support+::+\",
    \"lamProMailIsHTML\": \"false\",
    \"lamProMailAllowAlternateAddress\": \"true\",
    \"httpAuthentication\": \"false\",
    \"loginSearchDN\": \"\",
    \"loginSearchPassword\": \"\",
    \"timeZone\": \"Europe/London\",
    \"pwdResetAllowSpecificPassword\": \"true\",
    \"pwdResetAllowScreenPassword\": \"true\",
    \"pwdResetForcePasswordChange\": \"true\",
    \"pwdResetDefaultPasswordOutput\": \"2\",
    \"typeSettings\": {
        \"suffix_user\": \"ou=users,$LDAP_BASE\",
        \"attr_user\": \"#uid;#givenName;#sn;#uidNumber;#gidNumber\",
        \"modules_user\": \"inetOrgPerson,posixAccount,shadowAccount\",
        \"suffix_group\": \"ou=groups,$LDAP_BASE\",
        \"attr_group\": \"#cn;#gidNumber;#memberUID;#description\",
        \"modules_group\": \"posixGroup\"
    }
}
EOL"

# Ajustamos permisos para que LAM pueda leer los archivos
sudo chown ldap-account-manager:ldap-account-manager $LAM_CONFIG_DIR/config.cfg
sudo chown ldap-account-manager:ldap-account-manager $LAM_CONFIG_DIR/lam.conf
sudo chmod 600 $LAM_CONFIG_DIR/config.cfg
sudo chmod 600 $LAM_CONFIG_DIR/lam.conf
