#!/bin/bash

function _help(){  # Função para printar a descrição do script.
    echo "
    Script para criação de usuários com arquivo CSV.

    Argumento Posicional:

        file    Caminho do arquivo CSV com as informações a serem cadastradas.


    Argumento Opcional:

        --help    Mostra essa mensagem.


    Formato do arquivo:

        nome de login;nome completo;senha;grupo;diretorio home
    

    Observações:
        -> O arquivo não leva cabeçalho. Basta ter as informações dos usuários no formato mencionado.
        -> O arquivo de log será salvo sempre no diretório home do usuário que está executando o programa. O arquivo tem o nome "user_creation.log"
    "
}

function _check_user(){  # Função que valida se o usuário já se encontra cadastrado no sistema.
    _user=$1
    _users=`cut /etc/passwd -d: -f1`

    for user in $_users; do
        if [ "$_user" == "$user" ]; then
            echo 1  # Estranhamente é nesse echo que retona o valor que eu preciso.
            return
        fi
    done

    echo 0  # Estranhamente é nesse echo que retona o valor que eu preciso.
    return
}

function _creation_log(){
    _file="$HOME/user_creation.log"
    _login=$1
    _password=$( echo "$2" | md5sum )

    touch $_file
    echo "$_login;$_password;`date`" >> $_file
    
}

function main(){  # Executa a criação dos usuários.
    _file=$1  # Recebe o argumento passado na chamada da função.

    while read _line; do
        _login=$( echo "$_line" | cut -d\; -f1 )
        _name=$( echo "$_line" | cut -d\; -f2 )
        _password=$( echo "$_line" | cut -d\; -f3 )
        _group=$( echo "$_line" | cut -d\; -f4 )
        _home=$( echo "$_line" | cut -d\; -f5 )

        _is_valid=$( _check_user $_login )

        if [[ $_is_valid -eq 1 ]]; then
            echo "Usuário $_login já existe cadastrado."
        else
            echo "Criando o usuário: $_login"
            echo "$_home | $_group | $_password | $_name"
            sudo useradd -m -d "$_home" -G $_group -p $_password -c "$_name" $_login
            _creation_log $_login $_password
        fi
   done < $_file
}

# Verifica se foi passado o argumento posicional com o caminho do arquivo
if [ ! $1 -o $1 == "--help" ]; then
    _help
else
    main $1  # Captura o arquivo por linha de comando.
fi
