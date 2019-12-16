#!/bin/bash
# build gitbook in Docker
# @param repo, user/repo in GitHub, such as rstudio/bookdown-demo
# @param wd, directory containing .Rmd files
# @param url, website of original book
# @param niche, ecological space including installr, dongzhuoer.bookdown.com, _output/*yml
# @param apt, packages to install via APT
# @param command, bash command to run at $wd

    # docker rm -f rlang0
# create container
docker pull dongzhuoer/rlang:zhuoerdown 2> /dev/null
docker run -dt --name rlang0 -v $HOME/.local/lib/R:/usr/local/lib/R/site-library dongzhuoer/rlang:zhuoerdown
# prepare files
docker exec rlang0 git clone --depth 1 https://github.com/$repo.git /root/repo
    # mkdir -p _bookdown_files
docker cp _bookdown_files rlang0:/root/repo/$wd 
docker cp _output/$niche.yml rlang0:/root/_output.yml
# dependency
docker exec -w /root/repo/$wd rlang0 bash -c "$command"
docker exec rlang0 bash -c "apt update && apt install -y $apt"
docker exec -w /root/repo/$wd -e GITHUB_PAT=$GITHUB_PAT rlang0 Rscript -e "remotes::install_github('dongzhuoer/installr/$niche')"
docker exec -w /root/repo/$wd rlang0 Rscript -e "bookdown::render_book('', zhuoerdown::make_gitbook('$root', '/root/_output.yml'), output_dir = '/root/gitbook')"
docker exec rlang0 Rscript -e "file.copy(zhuoerdown:::pkg_file('bookdown.css'), '/root/gitbook')"
docker exec rlang0 chown -R `id -u`:`id -g` /usr/local/lib/R/site-library
rm -r _bookdown_files && docker cp rlang0:/root/repo/$wd/_bookdown_files . 
# wget https://gist.githubusercontent.com/dongzhuoer/c19d456cf8c1bd977a2f7916f61beee8/raw/cc-license.md
# docker cp cc-license.md rlang0:/gitbook/readme.md

#docker exec  rlang0 env

# git clone --depth 1 $repo_git $work_dir/repo && mv $work_dir/repo/.git $work_dir/output
# cd $work_dir/output && git add --all && git commit -m "travis build at `date '+%Y-%m-%d %H:%M:%S'`" --allow-empty && git push -f

# mv $work_dir/input/$wd/_bookdown_files $TRAVIS_BUILD_DIR || echo 'cache not available'
