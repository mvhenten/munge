rm -rf App
CURDIR=cwd
cd ../Munge-App/
dzil build
cd ../dotcloud/
cp -r ../Munge-App/Munge-App-0.01 App
