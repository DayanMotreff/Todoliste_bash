#!/bin/bash

init () {
    if [ -e todo.sauv ]
    then
        i=0
        while IFS= read -r line
        do
            base[$i]="$line"
            i=$i+1
        done < todo.sauv
    else
        base=()
    fi
}

create () {
    read -p "Quel est le nom de la tache à ajouter ? : " tache
    base=("${base[@]}" "$tache")
}


sauvegarde () {
    for i in ${!base[@]}
    do
        if [ $i -eq 0 ]
        then
            echo -e "${base[$i]}" > todo.sauv
        else
            echo -e "${base[$i]}" >> todo.sauv
        fi
    done
}

affichage () {
    echo -e "Num\tTaches"
    for i in ${!base[@]}
    do
        echo -e "$(($i+1))\t${base[$i]}"
    done
}

suppr () {
    affichage
    read -p "Quel est le Num de la tache à effacer ? : " numt
    basetemp=()
    for i in ${!base[@]}
    do
        if [ $i -ne $(($numt-1)) ]
        then
            basetemp=("${basetemp[@]}" "${base[$i]}")
        fi
    done
    base=()
    for i in ${!basetemp[@]}
    do
        base[$i]=${basetemp[$i]}
    done
    echo "Tache num $numt effacée !"
}

replace () {
    affichage
    read -p "Quel tache voulez vous deplacer ? : " tachemv
    read -p "Quel numero souhaitez vous lui assigner ? : " tachemv1
    temp=${base[$(($tachemv-1))]}
    basetemp=()
    if [ $tachemv -gt $tachemv1 ] # cas pour la destination < la tache a mv
    then
        for i in ${!base[@]}
        do
            if [ $i -eq $(($tachemv1-1)) ] # index egale a la destination
            then
                basetemp[$i]=$temp
                basetemp[$(($i+1))]=${base[$i]}
            elif [ $i -gt $(($tachemv1-1)) ] && [ "$temp" != "${base[$i]}" ] # index superieur a la destination et different de la tache a mv
            then
                if [ $(($i+1)) -gt $((${#base[@]}-1)) ]
                then
                    basetemp[$i]=${base[$i]}
                else
                    basetemp[$(($i+1))]=${base[$i]}
                fi
            elif [ $i -lt $(($tachemv1-1)) ] # index en dessous de la destination
            then
                basetemp[$i]=${base[$i]}
            fi
        done
    else # cas pour la destination > la tache a mv
        for i in ${!base[@]}
        do
            if [ $i -eq $(($tachemv1-1)) ] # index egale a la destination
            then
                basetemp[$i]=$temp
                basetemp[$(($i-1))]=${base[$i]}
            elif [ $i -lt $(($tachemv1-1)) ] && [ "$temp" != "${base[$i]}" ] # index inferieur a la destination et different de la tache a mv
            then
                if [ $(($i-1)) -lt 0 ]
                then
                    basetemp[$i]=${base[$i]}
                else
                    basetemp[$(($i-1))]=${base[$i]}
                fi
            elif [ $i -gt $(($tachemv1-1)) ] # index au dessus de la destination
            then
                basetemp[$i]=${base[$i]}
            fi
        done
    fi

    base=()
    for i in ${!basetemp[@]}
    do
        base[$i]=${basetemp[$i]}
    done
}

menu () {
    echo -e "\n############ Welcome to TODO Liste ##############\n"
    echo "1 ) Afficher le TODO liste"
    echo "2 ) Créer une nouvelle tache"
    echo "3 ) Supprimer une tache"
    echo "4 ) Changer l'ordre des taches"
    echo "5 ) Quitter et Sauvegarder"
    echo -e "\n################################################\n"
    choix=0
    until [[ $choix =~ [1-5] ]]
    do
        read -p "Votre choix : " choix
    done
}

init

while true
do
    sleep 1
    menu
    case $choix in
        1)
            affichage
            ;;
        2)
            create
            ;;
        3)
            suppr
            ;;
        4)
            replace
            ;;
        5)
            sauvegarde
            break
            ;;
    esac
done
