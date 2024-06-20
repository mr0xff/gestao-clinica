Sistema de Gestão de pacientes, funcionários e serviços
--------------------------------------------------------

Funcionalidades:
	- Cadastro, Listar e remover de funcionario, pacientes e serviço
	- Marcação de consultas: 
		- Escolher o médico
			- funcionario/conta do sistema
		- Escolher a hora a ser atendido
		- Controlar os casos de prioridades de atendimentos
			- baixa
			- alta
		...
	- Formas de pagamentos aceites:
		- A cash
		- Multicaixa
	- Verificação pacientes que há mais de duas semanas foram marcados como mortos e apagá-los do sistema
	- Backup das informações dos pacientes em uma partição
	
Problemas:
	- conflitos no acesso às informações
	- Sequencia adequada na prestação do serviço os clientes/pacientes


Arquitetura:
	- Cliente/Servidor
		Cliente: instâncias que se vão conectar ao servidor NFS
		servidor: instância que vai estar no servidor NFS

Nivel de Funcionários:
  enfermeiros:
    - Ler pacientes cadastrados
    - Cadastrar pacientes
    - 
  medicos:
    - Ler dados dos pacientes
    - Cadastro de serviços
    - Marcar consultas
    - Ler consultas
    - Cadastro de pacientes
    - Ler pacientes cadastrados
  administradores:
    - cadastro de funcionario
    - Verificar e apagar pacientes
    - Ver permissões dos funcionários 
    - Alterar permissões dos funcionários
    - Ver os backups feitos
    - Ver registros dos sistema
    - Fazer backups
