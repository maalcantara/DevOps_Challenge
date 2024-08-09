# DevOps_Challenge 💻 ♾️
O objetivo deste desafio é provisionar uma infraestrutura usando Infra-as-Code (IaC) Terraform que deve conter:

- Um cluster Kubernetes (AKS) na nuvem. 
- Configuração de rede e suas subnets.
- Configuração de segurança usando o princípio de privilégio mínimo.
- Uso de uma IAM role para permissões no cluster.
Aplicação das melhores práticas para provisionamento de recursos na nuvem.
- Localização do AKS em `central-us` com VMs do tamanho `Standard_DS2_v2`

**Service Principal (App Registration):** Serve para que o Terraform possa criar recursos no Azure através de uma autenticação pela Service Principal. `Microsoft Entra ID` → Add Application Registration.

- Autorização para a Service Principal: Subscriptions🔑 → Access Control (IAM) → Add Role Assignment → Privileged administrator roles. Isso possibilita criar recursos no Azure através do Terraform → que posteriormente será utilizado para atribuir a autorização 'acr pull' do Container Registry.

## Estrutura do Projeto 🏗️

### Diretório `backend-terraform`
Contém a configuração para provisionar os recursos **fixos** necessários para armazenar o estado do Terraform. Isso inclui a criação de um resource group, uma storage account, um container de armazenamento no Azure, e o recurso ACR (Azure Container Registry), que posteriormente irá armazenar a imagem docker gerada a partir do deploy da aplicação.

### Diretório `terraform` 🌱
Contém a configuração para provisionar o cluster AKS, a rede virtual e suas subnets. Este diretório utiliza o backend configurado para armazenar o estado (no arquivo .tfstate) do Terraform remotamente.

**🔵 Atualização (01/08/24):** adição do resource `container_registry`, que cria um Azure Container Registry (ACR), utilizado para armazenar as imagens Docker geradas a partir do build da aplicação.
- Além disso, foi configurado um `role_assignment` → 'acr pull' para garantir que o AKS tenha permissão para puxar imagens diretamente do ACR → facilitando o processo de deploy no cluster.

- 05/08/2024 - Adição de variáveis de saída (outputs) que capturam as informações necessárias do ACR (nome, servidor de login, usuário e senha).

### Diretório `dotnet-app`
Aplicativo web .NET básico de 'Hello World' que posteriormente será realizado o deploy desta aplicação no cluster AKS criado.

### Diretório `k8s` 🧭
Contém os arquivos de configuração necessários para o deploy da aplicação no cluster AKS. Esses arquivos incluem:
- `deployment.yml`: Define como a aplicação será implantada no cluster. Especifica detalhes como o número de réplicas, a imagem Docker a ser usada e outros parâmetros importantes para o deployment.

- `service.yml`: Define como a aplicação será exposta para o mundo exterior. Especifica o tipo de serviço (por exemplo, `LoadBalancer`), as portas a serem expostas e outras configurações necessárias para garantir que a aplicação seja acessível externamente.

### Dockerfile 🐋
O arquivo `Dockerfile` configura a construção de uma imagem Docker para sua aplicação .NET. Ele usa o .NET SDK para compilar e publicar a aplicação e o .NET Runtime para executá-la. O processo inclui copiar os arquivos, restaurar dependências, compilar a aplicação e definir o ponto de entrada.

## Workflows de Pipeline CI/CD 📥
Este repositório possui duas pipelines yaml configuradas utilizando GitHub Actions para **automatizar** o processo de provisionamento, gerenciamento da infraestrutura, build da aplicação e criação de uma imagem docker a partir deste build.

### 🧱 'terraform.yml': 
A pipeline realiza as seguintes etapas: 

1. Verifica a existência do resource group e, se existente, o destrói para evitar conflitos.
2. Inicializa o Terraform.
3. Valida a configuração do Terraform.
4. Gera e aplica o plano de execução do Terraform, criando todos os recursos detalhados no script.
5. Definir e exportar outputs (variáveis de saída), permitindo que sejam utilizadas em outros jobs, como na pipeline de build da aplicação.

### 🛠️ 'dotnet-build.yml': 
Com a adição do evento `workflow_run`, essa pipeline é executada após o êxito da 'terraform.yml', e realiza os seguintes passos:

#### 1° Job: build-dotnet
1. Configura o SDK do .NET Core.
2. Instala e executa o linting do código C# usando `dotnet-format`.
3. Analisa a qualidade do código com SonarCloud.
4. Realiza o build e publica o projeto .NET
5. Faz o upload do artefato de build.

#### 2° Job: build-docker-acr
6. Faz login no ACR, utilizando os outputs do Terraform.
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

→ Atualizar o path do acr em k8s/deployment.yml e o secret do actions. Tive que fazer isso porque adicionei o resource Container Registry (ACR) no main.tf do diretório principal.
→ Atualizar a role assignment do Terraform para Owner no resource group, garantindo que ele tenha as permissões necessárias para atribuir o papel AcrPull ao AKS, permitindo que o cluster acesse o Azure Container Registry (ACR) durante a execução do código.
→ Atualizar a role assignment do Terraform para 'Owner' no Azure Container Registry (ACR), garantindo que ele tenha as permissões necessárias para atribuir o papel AcrPull ao AKS. Isso permitirá que o cluster acesse o ACR durante a execução do código.

**Reunião O2M DevOps 06/08:** colocar o recurso de ACR no resouce group fixo (backend-terraform) → depois de provisionar, adicionar as credenciais do acr nos secrets do github e passar essas credenciais para a pipeline.

GitHub Templates: estudar!!