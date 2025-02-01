#!/bin/bash
echo ""
echo "┌────────────────────────────────────────┐"
echo ""
echo "   Glassy  ──  A glassy theme for KDE     "
echo ""
echo "   @therootuser_  "
echo ""
echo "└────────────────────────────────────────┘"
echo ""
sleep 0.5

# Some vars
THEME="Glassy"
wallpaper_file_name="2400x1350.jpg"
print(){ sleep 0.2; echo -e $1; }
dir_check(){ dir=$1; [[ ! -d $dir ]] && mkdir -p $dir; }

# modify settings only if installed
kvantum=false
wallpaper=false
sddm_config=false

if [[ $EUID -eq 0 ]]; then
    echo -e "[-] Please execute the script as normal user (without sudo). "
    sleep 1
    exit
fi


echo "┌─ Installing.."

if [ -d aurorae/$THEME ]; then
    print "├── aurorae theme "
    dir_check $HOME/.local/share/aurorae/themes
    cp aurorae/$THEME* $HOME/.local/share/aurorae/themes/ -r
fi

if [ -d gtk/$THEME ]; then
    print "├── gtk theme "
    dir_check $HOME/.themes
    cp gtk/$THEME $HOME/.themes/ -r
fi

if [ -f color-schemes/$THEME.colors ]; then
    print "├── color scheme "
    dir_check $HOME/.local/share/color-schemes
    cp color-schemes/$THEME.colors $HOME/.local/share/color-schemes/$THEME.colors
fi

if [ -f Kwrite-$THEME.theme ]; then
    # print "├── editor theme "
    dir_check $HOME/.local/share/org.kde.syntax-highlighting/themes
    cp Kwrite-$THEME.theme $HOME/.local/share/org.kde.syntax-highlighting/themes/Kwrite-$THEME.theme
fi

# done
if [ -d Kvantum/$THEME ]; then
    print "├── kvantum theme "
    dir_check $HOME/.config/Kvantum
    cp Kvantum/$THEME $HOME/.config/Kvantum/ -r
    kvantum=true
fi

if [ -d desktoptheme/$THEME ]; then
    print "├── desktop theme "
    dir_check $HOME/.local/share/plasma/desktoptheme
    cp desktoptheme/$THEME $HOME/.local/share/plasma/desktoptheme/ -r
fi

if [ -d look-and-feel/$THEME ]; then
    print "├── login/splash theme "
    dir_check $HOME/.local/share/plasma/look-and-feel
    cp look-and-feel/$THEME $HOME/.local/share/plasma/look-and-feel/ -r
    # cp look-and-feel/$THEME/contents/layouts/plasma-org.kde.plasma.desktop-appletsrc ~/.config/
fi

if [ -f konsole/$THEME.profile ]; then
    print "├── konsole theme "
    dir_check $HOME/.local/share/konsole
    cp konsole/$THEME.profile $HOME/.local/share/konsole/$THEME.profile
    [ -f konsole/$THEME.colorscheme ] && cp konsole/$THEME.colorscheme $HOME/.local/share/konsole/$THEME.colorscheme
fi

# done
if [ -d wallpapers/$THEME ]; then
    print "├── wallpapers "
    dir_check $HOME/.local/share/wallpapers
    cp wallpapers/* $HOME/.local/share/wallpapers/ -r
    wallpaper=true
fi

if [ -d icons/$THEME ]; then
    if [ ! -d $HOME/.local/share/icons/WhiteSur ]; then
    read -p "├── WhiteSur icon theme not found. Install it from web? (y/n) " INSTALL
        if [[ $INSTALL =~ ^[y|Y] ]]; then
            echo -e "│   Installing from web..."
        else
            echo -e "│   Icons installation aborted. Modifications not made."
        fi
    fi

    if [ -d $HOME/.local/share/icons/WhiteSur ]; then
        sleep 0.2; echo -e "├── custom icons "
        [ -d $HOME/.local/share/icons/$THEME ] && rm -rf $HOME/.local/share/icons/$THEME
        cp icons/$THEME $HOME/.local/share/icons/$THEME -r >/dev/null
    fi
fi

if [ -d plank/$THEME ]; then
    print "├── plank theme "
    dir_check $HOME/.local/share/plank/themes
    cp plank/* $HOME/.local/share/plank/themes/ -r
fi

# done
if [[ $1 = 'sddm' ]]; then
    if [ -d sddm/$THEME ]; then
        print "├── sddm theme "
        if ! $(sudo -n true 2>/dev/null); then echo -ne "│   Please provide "; fi
        [ ! -d /usr/share/sddm/themes/ ] && sudo mkdir -p /usr/share/sddm/themes
        sudo cp sddm/$THEME* /usr/share/sddm/themes/ -r
        sddm_config=true
    fi
elif [[ $1 = '' ]]; then
    sddm="eee"
fi

sleep 0.5
echo -e "│\n└─ Installation done."

[ $sddm == "eee" ] && print "\n[*] If you want to install sddm theme, execute: $0 sddm"



sleep 1
echo " "
echo -ne "┌─ Do You want to apply the theme? (y/n) "
read REPLY;
if [[ "$REPLY" =~ ^[y/Y]$ ]]; then   
    [ -f look-and-feel/$THEME/contents/layouts/plasma-org.kde.plasma.desktop-appletsrc ] && read -p "├─ Apply panel layout? (y/n) " PANEL
    echo -ne "├─ Applying theme"   
    sleep 0.4; echo -ne "."; sleep 0.4; echo -ne "."; sleep 0.4; echo -ne ". ";
    # echo $THEME > $HOME/.config/kdedefaults/package
    # echo -e "[Theme]\nname=$THEME" > $HOME/.config/kdedefaults/plasmarc
    [[ "$PANEL" =~ ^[y/Y]$ ]] && cp look-and-feel/$THEME/contents/layouts/plasma-org.kde.plasma.desktop-appletsrc ~/.config/
    lookandfeeltool -a $THEME 2>/dev/null
    $wallpaper && plasma-apply-wallpaperimage $HOME/.local/share/wallpapers/$THEME/contents/images/$wallpaper_file_name 1>/dev/null
    $wallpaper && sed -i "s|Image=.*|Image=$HOME/.local/share/wallpapers/$THEME/|g" $HOME/.config/kscreenlockerrc
    $wallpaper && sed -i "s|PreviewImage=.*|PreviewImage=$HOME/.local/share/wallpapers/$THEME/|g" $HOME/.config/kscreenlockerrc
    $kvantum && echo -e "[General]\ntheme=$THEME" > $HOME/.config/Kvantum/kvantum.kvconfig
    sed -i "s|ColorScheme=.*|ColorScheme=$THEME|g" $HOME/.config/kdeglobals
    sed -i "s|LookAndFeelPackage=.*|LookAndFeelPackage=$THEME|g" $HOME/.config/kdeglobals
    sed -i "s|Theme=.*|Theme=$THEME|g" $HOME/.config/kdedefaults/ksplashrc
    sed -i "s|Theme=.*|Theme=$THEME|g" $HOME/.config/kdedefaults/kscreenlockerrc
    sed -i "s|theme=.*|theme=__aurorae__svg__$THEME|g" $HOME/.config/kdedefaults/kwinrc
    sed -i "s|singleModeLayoutName=.*|singleModeLayoutName=$THEME|g" $HOME/.config/lattedockrc
    sed -i "s|DefaultProfile=.*|DefaultProfile=$THEME.profile|g" $HOME/.config/konsolerc
    $sddm_config && sudo sed "s|Current=.*|Current=$THEME|g" /etc/sddm.conf.d/kde_settings.conf
    # Do you also prefer MediumRounded applet when switching apps? I do :)
    [ -d $HOME/.local/share/kwin/tabbox/MediumRounded ] && sed -i "s|LayoutName=.*|LayoutName=MediumRounded|g" $HOME/.config/kwinrc
    sleep 0.5; echo -e "Applied."
else
    echo -ne "├─ Alright"
    sleep 0.3; echo -ne ".. "
    sleep 0.5; echo -ne "You don't get any candies "
    sleep 1; echo -ne "😏"; sleep 2
fi
echo ""
echo -e "└─ ^ Bye ^"