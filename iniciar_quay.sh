#!/bin/bash


function stop(){
	echo -e "Parando containers já iniciados"
	docker-compose -f ./docker-compose.yaml -f ./initial_config.yaml -f ./clair.yaml stop $1
	docker-compose -f ./docker-compose.yaml -f ./initial_config.yaml -f ./clair.yaml rm --force $1
}

function start(){
	echo -e "Iniciando Quay Registry $2"
	docker-compose -f ./docker-compose.yaml $1 up -d $3
}

function primeiraVez() {

	stop

	echo -e "Ajustando pasta do postgresql"
	chmod 777 ./postgresql -R
	sudo rm -rf ./postgresql/data/*

	start "-f ./initial_config.yaml" "Iniciando bancos e adicionando extensão" "redis postgresql"
	sleep 20
	docker-compose exec postgresql /bin/bash -c 'echo "CREATE EXTENSION IF NOT EXISTS pg_trgm" | psql -d ${POSTGRESQL_DATABASE} -U postgres'
	start "-f ./initial_config.yaml" "Iniciando web" "registry"
}

function alterarExistente(){
	stop "registry"

	echo -e "Iniciando containers"
	start "-f ./initial_config.yaml" "Iniciando web" "registry"
}

function configurado(){
	
	stop

	start
}

main(){
	clear
	echo -e "Digite uma opção"
	echo -e "\n1 -\tIniciar primeira instalação do Quay Registry"
	echo -e "2 -\tSomente iniciar Quay Registry já configurado"
	echo -e "3 -\tParar todos os containers"
	echo -e "4 -\tAlterar instalação existente"
	while [[ true ]]; do
		read opcao
		echo $pwd
		case $opcao in
			1) primeiraVez
				break
			;;
			2) configurado
				break
			;;
			3) stop
				break
			;;
			4) alterarExistente
				break
			;;
			*) echo -e "Opção inválida"
			;;
		esac
	done
}

main
