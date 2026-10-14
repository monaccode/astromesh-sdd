<p align="center">
  <img src="https://raw.githubusercontent.com/monaccode/astromesh-sdd/main/assets/logo.png" alt="Astromesh SDD" width="640">
</p>

# astromesh-sdd

**Skills de Spec-Driven Development para cualquier agente de código.**

[![astromesh-author](https://img.shields.io/badge/astromesh-author-8b5cf6)](https://monaccode.github.io/astromesh/#ecosystem)
[![Release](https://img.shields.io/github/v/release/monaccode/astromesh-sdd?label=release)](https://github.com/monaccode/astromesh-sdd/releases)
[![CI](https://github.com/monaccode/astromesh-sdd/actions/workflows/ci.yml/badge.svg)](https://github.com/monaccode/astromesh-sdd/actions/workflows/ci.yml)
[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-SKILL.md-1d4ed8)](https://agentskills.io)
[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-1fb4f2)](#claude-code)
[![License: Apache-2.0](https://img.shields.io/badge/license-Apache--2.0-blue)](https://github.com/monaccode/astromesh-sdd/blob/main/LICENSE)

*[Read in English](https://github.com/monaccode/astromesh-sdd/blob/main/README.md)*

Los agentes de código escriben rápido y se olvidan del porqué. Spec-Driven Development
ordena el trabajo: primero una **spec** de lo que tiene que ser cierto, después un **plan**
de cómo, después **tareas** chicas que se pueden verificar, después el código, y al final
una **verificación** contra la spec. `astromesh-sdd` empaqueta ese ciclo en siete skills.
Cada fase escribe un archivo Markdown junto a tu código, así la próxima sesión, alguien de
tu equipo u otro agente retoma exactamente donde quedó la anterior.

Las skills usan el formato abierto [Agent Skills](https://agentskills.io) (`SKILL.md`): la
misma carpeta funciona en Claude Code, Codex CLI, OpenCode, Kimi Code, Gemini CLI y GitHub
Copilot. Los agentes que no leen skills reciben el ciclo completo en un bloque de `AGENTS.md`.

```mermaid
%%{init: {"theme": "base", "themeVariables": {"primaryColor": "#0a2463", "primaryTextColor": "#ffffff", "cScale0": "#1d4ed8", "cScale1": "#0369a1", "cScale2": "#1e40af", "cScale3": "#0f766e", "cScale4": "#2563eb", "cScale5": "#0e7490", "cScaleLabel4": "#ffffff", "cScaleLabel5": "#ffffff", "cScaleLabel0": "#ffffff", "cScaleLabel1": "#ffffff", "cScaleLabel2": "#ffffff", "cScaleLabel3": "#ffffff"}}}%%
mindmap
  root((astromesh-sdd))
    El ciclo
      sdd-constitution
      sdd-specify
      sdd-plan
      sdd-tasks
      sdd-implement
      sdd-verify
    Archivos que deja
      constitution.md
      spec.md con REQ-n
      plan.md
      tasks.md con T-n
      verify.md
    Dónde corre
      Plugin de Claude Code
      Codex CLI
      OpenCode
      Kimi Code
      Gemini CLI
      GitHub Copilot
      AGENTS.md para el resto
    Hacelo tuyo
      .sdd/config.yaml
      tus plantillas
      reglas por fase
      tus propias fases
```

## El ciclo

```mermaid
%%{init: {"theme": "base", "themeVariables": {"primaryColor": "#0a2463", "primaryTextColor": "#ffffff", "cScale0": "#1d4ed8", "cScale1": "#0369a1", "cScale2": "#1e40af", "cScale3": "#0f766e", "cScale4": "#2563eb", "cScale5": "#0e7490", "cScaleLabel4": "#ffffff", "cScaleLabel5": "#ffffff", "cScaleLabel0": "#ffffff", "cScaleLabel1": "#ffffff", "cScaleLabel2": "#ffffff", "cScaleLabel3": "#ffffff"}}}%%
mindmap
  root((astromesh-sdd))
    The cycle
      sdd-constitution
      sdd-specify
      sdd-plan
      sdd-tasks
      sdd-implement
      sdd-verify
    Files it leaves
      constitution.md
      spec.md with REQ-n
      plan.md
      tasks.md with T-n
      verify.md
    Where it runs
      Claude Code plugin
      Codex CLI
      OpenCode
      Kimi Code
      Gemini CLI
      GitHub Copilot
      AGENTS.md for the rest
    Make it yours
      .sdd/config.yaml
      your templates
      rules per phase
      your own phases
```

## The cycle

```mermaid
%%{init: {"theme": "base", "themeVariables": {"primaryColor": "#e0f2fe", "primaryTextColor": "#0a2463", "primaryBorderColor": "#1d4ed8", "lineColor": "#1d4ed8"}}}%%
flowchart TB
    idea([idea]) --> S[specify: spec.md]
    S -->|aprobás| P[plan: plan.md]
    P -->|aprobás| T[tasks: tasks.md]
    T -->|aprobás| I[implement, una tarea por vez]
    I -->|siguiente tarea| I
    I --> V[verify: verify.md]
    V -->|PASS| done([listo])
    V -->|falta un requisito| S
    V -->|falla un check| I
```

1. **Specify** — requisitos numerados (`REQ-1`…) con criterios de aceptación
   Given/When/Then. Lo que no se sabe queda marcado `[NEEDS CLARIFICATION]`; nunca se inventa.
2. **Plan** — decisiones con la alternativa descartada, los archivos a tocar, riesgos y cómo
   se prueba cada requisito. Cada paso cita los requisitos que atiende.
3. **Tasks** — tareas chicas y ordenadas (`T-1`…), cada una con un comando que demuestra
   que está hecha.
4. **Implement** — una tarea por vez: test que falla, código mínimo, check en verde, tilde,
   commit. Un requisito nuevo vuelve a la spec antes de entrar al código.
5. **Verify** — corre tu suite de tests en el momento y traza cada requisito a sus tareas y
   su evidencia. PASS sólo cuando no queda nada sin cubrir.

La **constitution** es opcional: una lista corta de principios verificables del proyecto que
toda spec y todo plan tienen que respetar. La skill `sdd` mira qué archivos existen y le dice
al agente qué fase sigue.

## Instalación

```bash
git clone https://github.com/monaccode/astromesh-sdd
cd astromesh-sdd
```

| Agente | Instalar en tu proyecto | Usarlo |
|---|---|---|
| <a id="claude-code"></a>Claude Code | `/plugin marketplace add monaccode/astromesh-sdd`<br/>`/plugin install astromesh-sdd@astromesh` | `/astromesh-sdd:sdd` |
| Codex CLI | `./install.sh --target codex --dir ~/mi-proyecto` | `$sdd` |
| OpenCode | `./install.sh --target opencode --dir ~/mi-proyecto` | pedile la skill `sdd` |
| Kimi Code | `./install.sh --target kimi --dir ~/mi-proyecto` | `/skill:sdd` |
| Gemini CLI | `./install.sh --target gemini --dir ~/mi-proyecto` | se activa sola |
| GitHub Copilot | `./install.sh --target copilot --dir ~/mi-proyecto` | se activa sola |
| Cualquier otro | `./install.sh --target agents-md --dir ~/mi-proyecto` | lee `AGENTS.md` |

`--global` instala para todos tus proyectos. En Windows usá `.\install.ps1` con las mismas
opciones (`-Target`, `-Global`, `-Dir`). Codex, OpenCode, Kimi, Gemini y Copilot leen
`.agents/skills/`, así que una sola instalación sirve para todos; `./install.sh` sin
opciones instala para todos los agentes a la vez. Rutas, cómo invocar y cómo comprobar que
cargó en cada uno: **[docs/install.md](docs/install.md)** (en inglés).

## Hacelo tuyo

Nunca editás las skills que vienen en el paquete. Poné una carpeta `.sdd/` en tu proyecto
(o `~/.sdd/` para todos) — `./install.sh --init` crea una comentada:

- `config.yaml` — dónde viven las specs, en qué idioma se escriben los artefactos, los
  prefijos de IDs, qué fases esperan tu aprobación y qué comando cuenta como evidencia.
- `templates/spec.md` y compañía — tu propio formato de spec, plan, tasks o verify.
- `rules/specify.md`, `rules/all.md` — reglas extra para una fase o para todas.
- Fases nuevas (un ADR, un threat model) — copiá
  [`templates/my-phase`](templates/my-phase/SKILL.md) y agregala en `phases:`.

Recetas y referencia completa: **[docs/extending.md](docs/extending.md)** (en inglés).

## Contribuir

Issues y pull requests son bienvenidos. [CONTRIBUTING.md](CONTRIBUTING.md) explica cómo
correr los checks y cómo sumar una plataforma.

## Licencia

[Apache-2.0](LICENSE). Parte del ecosistema [Astromesh](https://monaccode.github.io/astromesh/).
