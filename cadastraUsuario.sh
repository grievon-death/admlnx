#!/bin/bash

function _help(){  # Função para printar a descrição do script.
    echo "
    Script para criação de usuários com arquivo CSV.

    Argumento Posicional:

        file    Caminho do arquivo CSV com as informações a serem cadastradas.


    Formato do arquivo (OBS: O arquivo não leva cabeçalho.):

        nome de login;nome completo;senha;grupo;diretorio home
    "
}

function _valida_usuario(){
    _user=$1
    _users=`cut /etc/passwd -d: -f1`

    for user in $_users; do
        if [ "$_user" == "$user" ]; then
            return 1
        fi
    done

    return 0
}

function main(){  # Executa a criação dos usuários.
    _file=$1  # Recebe o argumento passado na chamada da função.

    while read _line; do
        _login=$( echo "$_line" | cut -d\; -f1 )
        _nome=$( echo "$_line" | cut -d\; -f2 )
        _senha=$( echo "$_line" | cut -d\; -f3 )
        _grupo=$( echo "$_line" | cut -d\; -f4 )
        _home=$( echo "$_line" | cut -d\; -f5 )

        _is_valid=$( _valida_usuario $_login )

        echo "$_is_valid"

        if [[ $_is_valid -eq 1 ]]; then
            echo "Usuário $_login já existe cadastrado."
        else
            echo "$_login"
        fi
   done < $_file
}

# Verifica se foi passado o argumento posicional com o caminho do arquivo
if [ ! $1 -o $1 == "help" ]; then
    _help
else
    main $1  # Captura o arquivo por linha de comando.
fi
