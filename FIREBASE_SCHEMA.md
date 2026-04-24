# Documentação das Coleções Firebase - ClickAcademico

## Visão Geral

Projeto: `clickacademico-342da`
URL: `https://firestore.googleapis.com/v1/projects/clickacademico-342da/databases/(default)/documents`

> **Nota:** Os nomes dos campos seguem a convenção do banco Firebird de origem. A coleção `disciplinas` utiliza campos em **MAIÚSCULO** (ex: `CODIGO`, `NOME`). Outras coleções podem usar minúsculo ou camelCase.

---

## Coleções

### 1. `alunos`
Dados dos alunos matriculados.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `codigo` | integer | Código único do aluno |
| `nome` | string | Nome completo |
| `email` | string | E-mail |
| `telefone` | string | Telefone |
| `ativo` | integer | 1=ativo, 0=inativo |
| `data_cadastro` | timestamp | Data de cadastro |

---

### 2. `alunos_online`
Credenciais de acesso dos alunos ao portal.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `codigo_aluno` | integer | FK para alunos |
| `nome_aluno` | string | Nome do aluno |
| `usuario` | string | Login |
| `senha` | string | Senha (criptografada em texto plano atualmente) |
| `primeiro_login` | boolean | true=primeiro acesso |
| `ativo` | integer | 1=ativo, 0=inativo |

---

### 3. `boletim_alunos`
Notas e faltas dos alunos por disciplina.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `codigoaluno` | integer | FK para aluno |
| `codigodisciplina` | integer | FK para disciplinas |
| `nome_disciplina` | string | Nome da disciplina (denormalizado) |
| `ano_letivo` | integer | Ano letivo |
| `media_1b` | double | Média 1º bimestre |
| `media_2b` | double | Média 2º bimestre |
| `media_3b` | double | Média 3º bimestre |
| `media_4b` | double | Média 4º bimestre |
| `b1` | integer | Faltas 1º bimestre |
| `b2` | integer | Faltas 2º bimestre |
| `b3` | integer | Faltas 3º bimestre |
| `b4` | integer | Faltas 4º bimestre |
| `totfaltas` | integer | Total de faltas |
| `recup` | double | Nota de recuperação |
| `mediaanual` | double | Média anual calculada |
| `mediaanualfinal` | double | Média final após recuperação |
| `situacao` | string | Aprovado/Reprovado/Recuperação |
| `id_envio` | string | FK para envio_boletins |
| `data_envio` | timestamp | Data do envio |

---

### 4. `config_boletim`
Configurações do boletim escolar.

**Documento:** `config_principal`

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `nome_escola` | string | Nome da instituição |
| `endereco` | string | Endereço |
| `telefone` | string | Telefone |
| `email` | string | E-mail de contato |
| `site` | string | Website |
| `titulo` | string | Título do boletim |
| `logo_base64` | string | Logo em base64 |
| `cor_primaria` | string | Cor primária (hex) |
| `cor_secundaria` | string | Cor secundária (hex) |
| `ordem_disciplinas` | array | Ordenação das disciplinas (ver estrutura abaixo) |
| `data_atualizacao` | timestamp | Última atualização |

#### Estrutura de `ordem_disciplinas`:
```json
{
  "arrayValue": {
    "values": [
      {"integerValue": 1},   // Código disciplina Português
      {"integerValue": 2},   // Código disciplina Matemática
      {"integerValue": 5},   // Código disciplina História
      ...
    ]
  }
}
```

---

### 5. `cursos`
Cursos oferecidos pela instituição.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `codigo` | integer | Código único |
| `nome` | string | Nome do curso |
| `descricao` | string | Descrição |
| `ativo` | integer | 1=ativo, 0=inativo |

---

### 6. `disciplinas`
Disciplinas cadastradas. **Campos em MAIÚSCULO** (convenção Firebird).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `CODIGO` | integer | Código único da disciplina |
| `NOME` | string | Nome da disciplina |
| `DESCRICAO` | string | Descrição |
| `ATIVO` | integer | 1=ativo, 0=inativo |
| `CARGA_HORARIA` | integer | Carga horária em horas |

---

### 7. `envio_boletins`
Registro de envios de boletins.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id_envio` | string | UUID do envio |
| `ano_letivo` | integer | Ano letivo |
| `data_envio` | timestamp | Data/hora do envio |
| `total_alunos` | integer | Quantidade de alunos |
| `total_disciplinas` | integer | Quantidade de disciplinas |
| `status` | string | Processando/Concluído/Erro |
| `usuario_envio` | string | Usuário que enviou |

---

### 8. `matriculas`
Matrículas dos alunos em turmas.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `codigo_aluno` | integer | FK para alunos |
| `codigo_turma` | integer | FK para turmas |
| `ano_letivo` | integer | Ano letivo |
| `data_matricula` | timestamp | Data da matrícula |
| `ativo` | integer | 1=ativo, 0=inativo |

---

### 9. `professores`
Dados dos professores.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `codigo` | integer | Código único |
| `nome` | string | Nome completo |
| `email` | string | E-mail |
| `telefone` | string | Telefone |
| `ativo` | integer | 1=ativo, 0=inativo |

---

### 10. `professores_online`
Credenciais de acesso dos professores.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `codigo_professor` | integer | FK para professores |
| `nome_professor` | string | Nome do professor |
| `usuario` | string | Login |
| `senha` | string | Senha |
| `primeiro_login` | boolean | true=primeiro acesso |
| `ativo` | integer | 1=ativo, 0=inativo |

---

### 11. `turmas`
Turmas/cursos.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `codigo` | integer | Código único |
| `nome` | string | Nome da turma |
| `codigo_curso` | integer | FK para cursos |
| `ano_letivo` | integer | Ano letivo |
| `ativo` | integer | 1=ativo, 0=inativo |

---

## Chaves de API

```
FIREBASE_PROJECT = 'clickacademico-342da'
FIREBASE_API_KEY = 'AIzaSyA2-w2UfVhzN2prqJ2H0kecHYwLTC3XbkU'
```

## Endpoints da API REST

### Buscar documentos:
```
GET /{collectionId}?key={API_KEY}
```

### Buscar documento específico:
```
GET /{collectionId}/{documentId}?key={API_KEY}
```

### Query com filtro:
```
POST /:runQuery?key={API_KEY}
Body: {"structuredQuery": {...}}
```

### Atualizar documento:
```
PATCH /{collectionId}/{documentId}?key={API_KEY}&updateMask.fieldPaths={campo1}&updateMask.fieldPaths={campo2}
```
