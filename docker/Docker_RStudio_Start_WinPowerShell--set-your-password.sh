$CURRENT_DIR=${PWD}
Write-Output ""
Write-Output "Starting container r-for-2011-ieac"
docker run -d --rm -p 28787:8787 --name r-for-2011-ieac-rstudio -e PASSWORD=rstudio -v ${CURRENT_DIR}/..:/home/rstudio/2011-ieac sdesabbata/r-for-2011-ieac
Write-Output "Container running at http://127.0.0.1:28787"
Write-Output "Username: rstudio"
Write-Output "Password: rstudio"