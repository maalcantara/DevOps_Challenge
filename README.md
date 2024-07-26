# DevOps_Challenge 💻
O objetivo deste desafio é provisionar uma infraestrutura usando Infra-as-Code (IaC) Terraform que deve contém:

- Um cluster Kubernetes (AKS) na nuvem. 
- Configuração de rede e suas subnets.
- Configuração de segurança usando o princípio de privilégio mínimo.
- Uso de uma IAM role para permissões no cluster.
Aplicação das melhores práticas para provisionamento de recursos na nuvem.
- Localização do AKS em `central-us` com VMs do tamanho `Standard_DS2_v2`

## Estrutura do Projeto 🏗️

### Diretório `backend-terraform`
Contém a configuração para provisionar os recursos **fixos** necessários para armazenar o estado do Terraform. Isso inclui a criação de um resource group, uma storage account e um container de armazenamento no Azure.

### Diretório `terraform`
Contém a configuração para provisionar o cluster AKS, a rede virtual e suas subnets. Este diretório utiliza o backend configurado para armazenar o estado (no arquivo .tfstate) do Terraform remotamente.

### Diretório `dotnet-app`
Aplicativo web .NET básico ...

## Workflow de Pipeline CI/CD 📥
Uma pipeline yaml foi configurada usando GitHub Actions para **automatizar** o processo de provisionamento e gerenciamento da infraestrutura. 

A pipeline realiza as seguintes etapas: 

1. Verifica a existência do resource group e, se existente, o destrói para evitar conflitos.
2. Inicializa o Terraform.
3. Valida a configuração do Terraform.
4. Gera e aplica o plano de execução do Terraform.

## Próximos passos: ➡️
- pipeline de build .NET
- validar código .net com Lint (regras)
- step de validação do lint antes do build
- salvar imagem docker no artifact e ACR
- próximo job: deploy no cluster AKS