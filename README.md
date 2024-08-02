# DevOps_Challenge 💻 ♾️
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

### Diretório `terraform` 🌱
Contém a configuração para provisionar o cluster AKS, a rede virtual e suas subnets. Este diretório utiliza o backend configurado para armazenar o estado (no arquivo .tfstate) do Terraform remotamente.

**🔵 Atualização (01/08/24):** adição do resource `container_registry`, que cria um Azure Container Registry (ACR), utilizado para armazenar as imagens Docker geradas a partir do build da aplicação.
- Além disso, foi configurado um `role_assignment` para garantir que o AKS tenha permissão para puxar imagens diretamente do ACR → facilitando o processo de deploy no cluster.

### Diretório `dotnet-app`
Aplicativo web .NET básico de 'Hello World' que posteriormente será realizado o deploy desta aplicação no cluster AKS criado.

### Diretório `k8s` 🧭
Contém os arquivos de configuração necessários para o deploy da aplicação no cluster AKS. Esses arquivos incluem:
- `deployment.yml`: Define como a aplicação será implantada no cluster. Especifica detalhes como o número de réplicas, a imagem Docker a ser usada e outros parâmetros importantes para o deployment.

- `service.yml`: Define como a aplicação será exposta para o mundo exterior. Especifica o tipo de serviço (por exemplo, `LoadBalancer`), as portas a serem expostas e outras configurações necessárias para garantir que a aplicação seja acessível externamente.

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

#### 3° Job: deploy-aks
11. Obtém as credenciais para acessar o cluster AKS que foi criado.
12. Faz o deploy da aplicação (contida na imagem Docker) no cluster AKS.
13. Expõe a aplicação para ser acessada externamente - atráves de um IP público.

## Próximos passos: ➡️
- pipeline de build .NET
- validar código .net com Lint (regras)
- step de validação do lint antes do build
- salvar imagem docker no artifact e ACR
- próximo job: deploy no cluster AKS

**Parei aqui:** a pipeline de deploy funciona, ao verificar 'Workloads' do cluster AKS, o 'Ready' aparece 0/1 - descobrir por quê e como resolver.

→ Atualizar o path do acr em k8s/deployment.yml e o secret do actions.
