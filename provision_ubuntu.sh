#!/usr/bin/env bash

set -e

#sudo yum groupinstall 'Development Tools'
#sudo yum install ncurses-devel openssl-devel perl-devel perl-CPAN

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install vim git ncurses-dev autoconf zlib1g-dev
sudo apt-get install i3 dmenu
#git clone https://github.com/Limvot/vim_config.git
#cd vim_config
#git submodule init
#git submodule update
#./setup.sh



cd
if ! [ -s "packages" ]
then
    mkdir packages
fi
cd packages

if ! [ -s "installed" ]
then
    mkdir installed
fi
PREFIX=$(pwd)/installed
if ! [ -s "added_to_bashrc" ]
then
    echo "export PATH=$PREFIX/bin:\$PATH" >> ~/.bashrc
    echo "export LD_LIBRARY_PATH=$PREFIX/lib:\$LD_LIBRARY_PATH" >> ~/.bashrc
    echo "added" > added_to_bashrc
fi

easy_pkg() {
    FOLDER=$1
    URL=$2
    ARCHIVE="${URL##*/}"
    echo "$URL, $ARCHIVE, $FOLDER"

    if ! [ -s "$ARCHIVE" ]
    then
        wget $URL
    fi

    if ! [ -s "$FOLDER.finished" ]
    then
        echo "$FOLDER.finished does not exist"
        if [ -s "$FOLDER" ]
        then
            rm -r "$FOLDER"
        fi

        mkdir "$FOLDER"
        cd "$FOLDER"
        cp "../$ARCHIVE" ./

        tar xf $ARCHIVE

        # bit of a hack - it might not extract to the same name, but hopefully the name is in it...
        # this is also why we do everything inside a folder we make, which is cleaner anyway
        cd *$FOLDER*

        # git (maybe others) don't have the configure script by default
        if ! [ -s "configure" ]
        then
            make configure
        fi

        env CPPFLAGS="-I$PREFIX/include/" LDFLAGS="-L$PREFIX/lib/" ./configure --prefix=$PREFIX
        make
        make install
        cd ../..
        echo "finished" > "$FOLDER.finished"
    fi
}

easy_pkg libevent https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz
easy_pkg tmux https://github.com/tmux/tmux/releases/download/2.3/tmux-2.3.tar.gz
easy_pkg vim https://github.com/vim/vim/archive/v8.0.0596.tar.gz
easy_pkg curl https://curl.haxx.se/download/curl-7.54.0.tar.gz
easy_pkg git https://github.com/git/git/archive/v2.12.2.tar.gz

# suckless st
if ! [ -s st ]
then
    sudo apt install libx11-dev libxft-dev libxext-dev
    #sudo yum install libX11-devel libXft-devel libXext-devel
    git clone git://git.suckless.org/st
    cd st
    git checkout tags/0.7
    cp ~/vim_config/config.h ./
    sed 's#PREFIX =.*#PREFIX = '$PREFIX'#g' config.mk -i
    make clean install
fi
