rm -rf App
cd ../Munge-App/
dzil build
cd ../dotcloud/
cp -r ../Munge-App/Munge-App-0.01 App
rm -rf ../Munge-App/Munge-App-0.01*
ln -s public App/static
dotcloud push
