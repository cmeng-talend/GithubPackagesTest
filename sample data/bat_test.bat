ECHO OFF
CLS
SET configError=0

SET JAVA_HOME=..\jre
SET JAVA_BRIDGE_HOME=..\java

SET HIVE_DRIVERS_PATH=
SET HIVE_JDBC_URL=
SET HIVE_USER=
SET HIVE_PASSWORD=
SET HIVE_USER_PROXY=
SET KERBEROS_CONFIG_FILE=
SET KERBEROS_KEYTAB_FILE=
SET ENABLE_KERBEROS_DEBUG=TRUE

IF NOT EXIST "%JAVA_HOME%" call :not_exist_err "Java Home %JAVA_HOME%"
IF NOT EXIST "%HIVE_DRIVERS_PATH%" call :not_exist_err "Hive drivers directory %HIVE_DRIVERS_PATH%"
IF NOT EXIST "%JAVA_BRIDGE_HOME%" call :not_exist_err "Bridge Java directory %JAVA_BRIDGE_HOME%"
IF NOT EXIST "%JAVA_BRIDGE_HOME%\ApacheHive.jar" call :not_exist_err "%JAVA_BRIDGE_HOME%\ApacheHive.jar"
IF NOT EXIST "%JAVA_BRIDGE_HOME%\Mimb.jar" call :not_exist_err "%JAVA_BRIDGE_HOME%\Mimb.jar"
IF DEFINED KERBEROS_KEYTAB_FILE (@IF NOT EXIST "%KERBEROS_KEYTAB_FILE%" call :not_exist_err "Keytab keytab file '%KERBEROS_KEYTAB_FILE%'")
IF DEFINED KERBEROS_CONFIG_FILE (@IF NOT EXIST "%KERBEROS_CONFIG_FILE%" call :not_exist_err "Kerberos config file '%KERBEROS_CONFIG_FILE%'")

IF %configError%==1 goto:eof

SET MIR_CP=%JAVA_BRIDGE_HOME%\ApacheHive.jar;
SET MIR_CP=%MIR_CP%;%JAVA_BRIDGE_HOME%\Mimb.jar
SET KERBEROS_DEBUG_FLAG=
IF "%ENABLE_KERBEROS_DEBUG%"=="TRUE" (SET KERBEROS_DEBUG_FLAG="-Djavax.net.debug=ssl -Dsun.security.krb5.debug=true")

SET HIVE_CP=
for %%f in ("%HIVE_DRIVERS_PATH%\*.jar") do ( call :contactenate_path "%%f " )

"%JAVA_HOME%\bin\java" "-Xms256m" "-Xmx2048m" %KERBEROS_DEBUG_FLAG% -cp .;%MIR_CP%;"%HIVE_CP%" MITI.bridges.hive.Import.metadata.HiveImportBridge -jdbcUrl:%HIVE_JDBC_URL% -user:%HIVE_USER% -password:%HIVE_PASSWORD% -userProxy:%HIVE_USER_PROXY% -kerberosConfig:%KERBEROS_CONFIG_FILE% -kerberosKeytab:%KERBEROS_KEYTAB_FILE% -hiveDriversPath:%HIVE_DRIVERS_PATH%

goto:eof

:contactenate_path
SET pathElement=%1
SET HIVE_CP=%HIVE_CP%%pathElement:"=%;
goto:eof

:not_exist_err
ECHO '%1' does not exists
SET configError=1
goto:eof
