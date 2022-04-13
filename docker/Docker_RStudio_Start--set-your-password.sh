CURRENT_DIR=${PWD}
echo ""
echo "Starting container r-for-2011-ieac"
docker run -d --rm -p 28787:8787 --name r-for-2011-ieac-rstudio -e PASSWORD=rstudio -v $CURRENT_DIR/..:/home/rstudio/2011-ieac sdesabbata/r-for-2011-ieac
echo "Container running at http://127.0.0.1:28787"
echo "Username: rstudio"
echo "Password: rstudio"