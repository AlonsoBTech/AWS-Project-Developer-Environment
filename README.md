# AWS Developer Environment
![image](https://github.com/AlonsoBTech/AWS-Project-Developer-Environment/assets/160416175/5b246a3a-34c5-476b-9bc2-531fdefa196d)

## 📋 <a name="table">Table of Contents</a>

1. 🤖 [Introduction](#introduction)
2. ⚙️ [Prerequisites](#prerequisites)
3. 🔋 [What Is Being Created](#what-is-being-created)
4. 🤸 [Quick Guide](#quick-guide)
5. 🕸️ [Snippets](#snippets)
6. 🔗 [Links](#links)
7. 🚀 [More](#more)


## <a name="introduction">🤖 Introduction</a>

Creating an environment in AWS for developers. This environment will have an EC2 deployed that has docker installed
and ready to use for spinning up containers when needed.

## <a name="prerequisites">⚙️ Prerequisites</a>

Make sure you have the following:

- AWS Account
- AWS IAM User
- Terraform Installed
- IDE of choice to write Terraform code

## <a name="what-is-being-created">🔋 What Is Being Created</a>

What we will be creating:

- VPC
- VPC Subnet
- VPC Internet Gateway
- VPC Route Table
- VPC Route Table Route
- VPC Route Table Association
- EC2

## <a name="quick-guide">🤸 Quick Guide</a>

**First create your git repository (name it whatever you like) then clone the git repository**

```bash
git clone https://github.com/AlonsoBTech/AWS-Project-Developer-Environment.git
cd AWS-Project-Developer-Environment
```

**Create your Terraform providers.tf file**

</details>

<details>
<summary><code>providers.tf</code></summary>

