#!/bin/bash


# create container
docker pull dongzhuoer/ci:base > /dev/null
    # docker rm -f travis
docker run -dt --name travis -w /root dongzhuoer/ci:base
docker exec travis rm .bashrc .profile
docker exec travis bash -c 'echo -e "[user]\n\tname = Zhuoer Dong\n\temail = dongzhuoer@mail.nankai.edu.cn\n" > .gitconfig'

# fetch gitbook
docker exec travis mkdir {hadley,tidyverse,yihui,zhuoer}
docker exec travis git clone --depth 1 -b rstudio/bookdown-demo  https://github.com/dongzhuoer/bookdown.dongzhuoer.com.git rstudio/bookdown-demo
docker exec travis git clone --depth 1 -b hadley/r4ds            https://github.com/dongzhuoer/bookdown.dongzhuoer.com.git hadley/r4ds
docker exec travis git clone --depth 1 -b hadley/adv-r           https://github.com/dongzhuoer/bookdown.dongzhuoer.com.git hadley/adv-r
docker exec travis git clone --depth 1 -b hadley/r-pkgs          https://github.com/dongzhuoer/bookdown.dongzhuoer.com.git hadley/r-pkgs
docker exec travis git clone --depth 1 -b rstudio/rmarkdown-book https://github.com/dongzhuoer/bookdown.dongzhuoer.com.git rstudio/rmarkdown-book
docker exec travis git clone --depth 1 -b rstudio/bookdown       https://github.com/dongzhuoer/bookdown.dongzhuoer.com.git rstudio/bookdown  
docker exec travis git clone --depth 1 -b rstudio/blogdown       https://github.com/dongzhuoer/bookdown.dongzhuoer.com.git rstudio/blogdown
docker exec travis git clone --depth 1 -b tidyverse/style        https://github.com/dongzhuoer/bookdown.dongzhuoer.com.git tidyverse/style
docker exec travis git clone --depth 1 -b tidyverse/tidyeval     https://github.com/dongzhuoer/bookdown.dongzhuoer.com.git tidyverse/tidyeval
docker exec travis git clone --depth 1 -b yihui/r-ninja          https://github.com/dongzhuoer/bookdown.dongzhuoer.com.git yihui/r-ninja
docker exec travis bash -c "rm -rf */*/.git"

# auxiliary files
docker exec travis touch .nojekyll
docker exec travis bash -c "echo bookdown.dongzhuoer.com > CNAME"
docker cp index.md travis:/root && docker exec travis pandoc index.md -s -o index.html
docker exec travis wget -O readme.md https://raw.githubusercontent.com/dongzhuoer/gist/master/cc-license.md

# push to gh-pages
docker exec travis git clone --depth 1 -b gh-pages https://$GITHUB_PAT@github.com/dongzhuoer/bookdown.dongzhuoer.com.git git 
docker exec travis mv git/.git .
docker exec travis rm -rf git
docker exec travis git add --all
docker exec travis git commit -m "Travis build at `date '+%Y-%m-%d %H:%M:%S'`" --allow-empty 
docker exec travis git push
