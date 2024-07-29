# DevOps_Challenge 💻
O objetivo deste desafio é provisionar uma infraestrutura usando Infra-as-Code (IaC) Terraform que deve conter:

- Um cluster Kubernetes (AKS) na nuvem. 
- Configuração de rede e suas subnets.
- Configuração de segurança usando o princípio de privilégio mínimo.
- Uso de uma IAM role para permissões no cluster.
Aplicação das melhores práticas para provisionamento de recursos na nuvem.
- Localização do AKS em `central-us` com VMs do tamanho `Standard_DS2_v2`

## Estrutura do Projeto 🏗️

### Diretório `backend-terraform`
Contém a configuração para provisionar os recursos **fixos** necessários para armazenar o estado do Terraform. Isso inclui a criação de um resource group, uma storage account, um container de armazenamento no Azure, e o recurso ACR (Azure Container Registry), que posteriormente irá armazenar a imagem docker gerada a partir da execução da aplicação.

### Diretório `terraform`
Contém a configuração para provisionar o cluster AKS, a rede virtual e suas subnets. Este diretório utiliza o backend configurado para armazenar o estado (no arquivo .tfstate) do Terraform remotamente.

### Diretório `dotnet-app`
Aplicativo web .NET básico de 'Hello World' que posteriormente será realizado o deploy desta aplicação no cluster AKS criado.

## Workflow de Pipeline CI/CD 📥
Este repositório possui duas pipelines yaml configuradas utilizando GitHub Actions para **automatizar** o processo de provisionamento, gerenciamento da infraestrutura, build da aplicação e criação de uma imagem docker a partir deste build.

### 🧱 'terraform.yml': 
A pipeline realiza as seguintes etapas: 

1. Verifica a existência do resource group e, se existente, o destrói para evitar conflitos.
2. Inicializa o Terraform.
3. Valida a configuração do Terraform.
4. Gera e aplica o plano de execução do Terraform, criando todos os recursos detalhados no script.

### 🛠️ 'dotnet-build.yml': 
Com a adição do evento `workflow_run`, essa pipeline é executada após o êxito da 'terraform.yml', e realiza os seguintes passos:

#### 1° Job: build-dotnet
1. Configura o SDK do .NET Core.
2. Instala e executa o linting do código C# usando `dotnet-format`.
3. Analisa a qualidade do código com SonarCloud.
4. Realiza o build e publica o projeto .NET
5. Faz o upload do artefato de build.

#### 2° Job: build-docker-acr
6. Faz login no ACR.
7. Constrói a imagem Docker.
8. Salva a imagem Docker em um arquivo tar.
9. Realiza o upload do artefato da imagem Docker no actions.
10. Faz o envio (push) da imagem Docker para o ACR.

## Próximos passos: ➡️
- pipeline de build .NET
- validar código .net com Lint (regras)
- step de validação do lint antes do build
- salvar imagem docker no artifact e ACR
- próximo job: deploy no cluster AKS
