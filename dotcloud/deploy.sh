rm -rf App
rm -rf static
cd ../Munge-App/
dzil build
cd ../dotcloud/
cp -r ../Munge-App/Munge-App-0.01 App
rm -rf ../Munge-App/Munge-App-0.01*
cp -r App/public static
dotcloud push
