#!/bin/bash


function stop(){
	echo -e "Parando containers já iniciados"
	docker-compose -f ./docker-compose.yaml -f ./initial_config.yaml -f ./clair.yaml down
}

function start(){
	echo -e "Iniciando Quay Registry $2"
	docker-compose -f ./docker-compose.yaml $1 up -d
}

function primeiraVez() {

	stop

	echo -e "Ajustando pasta do postgresql"
	chmod 777 ./postgresql -R
	sudo rm -rf ./postgresql/data/*

	start "-f ./initial_config.yaml" "primeira configuração"
	sleep 20
	docker-compose exec postgresql /bin/bash -c 'echo "CREATE EXTENSION IF NOT EXISTS pg_trgm" | psql -d ${POSTGRES_DB} -U ${POSTGRES_USER}'
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
			*) echo -e "Opção inválida"
			;;
		esac
	done
}

main
