# Guia de Contribuição

Obrigado por dedicar tempo para contribuir com o template **Livro Markdown**. As diretrizes abaixo ajudam a manter a consistência do conteúdo e dos artefatos gerados.

## Requisitos de Ambiente

- [Pandoc](https://pandoc.org/) 2.18 ou superior instalado e acessível no `PATH`.
- Para gerar PDF, instale também `xelatex` (ex.: pacote `texlive-xetex`).
- `make` disponível no sistema (GNU Make recomendado).
- Opcional: [`pre-commit`](https://pre-commit.com/) para executar verificações antes dos commits.

Após instalar `pre-commit`, habilite os hooks:

```bash
pre-commit install
```

## Fluxo de Trabalho

1. Crie um branch descrevendo a alteração (ex.: `feature/__PROJECT_SLUG__-capitulo-novo`, `fix/__PROJECT_SLUG__-ajuste-metadata`).
2. Garanta que novos capítulos sigam o padrão `NN-nome.md` dentro de `chapters/`.
3. Atualize os arquivos de configuração em `config/` quando adicionar capítulos ou metadados.
4. Rode `make all` para verificar se todos os formatos são gerados corretamente.
5. Execute `pre-commit run --all-files` antes de abrir o *pull request*.

## Estilo de Conteúdo

- Utilize Markdown puro; evite HTML embutido salvo quando necessário.
- Prefira títulos com numeração consistente (`# Capítulo N`).
- Registre notas soltas em `notes/` e mantenha rascunhos em `drafts/`.
- Atualize `characters/` e `worldbuilding/` sempre que introduzir novos elementos narrativos.

## Licença

Respeite a licença ativa do projeto (`__PROJECT_LICENSE__`, veja `LICENSE`) ao submeter contribuições.

## Envios

- Inclua uma descrição clara do propósito do *pull request*.
- Referencie issues relacionadas quando aplicável.
- Certifique-se de que nenhuma saída gerada (`output/__PROJECT_SLUG__.*`) seja adicionada ao versionamento.

Apreciamos seu apoio ao template! Em caso de dúvidas, abra uma issue para discutirmos.
