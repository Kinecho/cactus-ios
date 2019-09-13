
#!/usr/bin/env bash

filename=.sentryclirc

if [ ! -f $filename ]
then
echo "Sentry config did not exist, creating it now"
touch $filename

echo "[auth]" >> $filename
echo "token=$(SENTRY_AUTH_TOKEN)" >> $filename
echo "[defaults]" >> $filename
echo "org=kinecho" >> $filename
echo "project=cactus-ios" >> $filename

echo "Created Sentry Config File using Env Variables"
else
echo "Sentry config exists"
fi


if ! [ -x  "$(command -v sentry-cli)" ]
then
echo "sentry-cli is not installed. Installing it now"
curl -sL https://sentry.io/get-cli/ | bash
else
echo "sentry-cli is installed. Continuing"
fi


echo "finished sentry-cli setup"

# Type a script or drag a script file from your workspace to insert its path.if which sentry-cli >/dev/null; then
#export SENTRY_ORG=kinecho
#export SENTRY_PROJECT=cactus-ios
#export SENTRY_AUTH_TOKEN=$(npx firebase functions:config:get sentry.api_token -P cactus-app-prod | sed -e 's/^"//' -e 's/"$//' ) 
ERROR=$(sentry-cli upload-dif "$DWARF_DSYM_FOLDER_PATH" 2>&1 >/dev/null)
if [ ! $? -eq 0 ]; then
echo "warning: sentry-cli - $ERROR"
fi
echo "warning: sentry-cli not installed, download from https://github.com/getsentry/sentry-cli/releases"fi
