SHELL          := /bin/bash
.SHELLFLAGS    := -eu -o pipefail -c
.DEFAULT_GOAL  := help

ROOT           := $(abspath $(CURDIR))

.PHONY: help
help: ## Show available targets
	@awk 'BEGIN{FS=":.*##"; printf "\nTargets:\n"} /^[a-zA-Z_-]+:.*##/ {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: install
install: ## Install both packages
	$(MAKE) -C .agents/skills/agent-skill-kit-commons/packages/mjs install
	$(MAKE) -C .agents/skills/agent-skill-kit-commons/packages/py install

.PHONY: ci
ci: ## Run CI for both packages
	$(MAKE) -C .agents/skills/agent-skill-kit-commons/packages/mjs ci
	$(MAKE) -C .agents/skills/agent-skill-kit-commons/packages/py ci

.PHONY: parity
parity: ## Run all 6 parity scripts (validate/audit/deps + registry + lint + prompt + read-properties + optimize)
	bash .agents/skills/agent-skill-kit-commons/scripts/run-parity.sh
	bash .agents/skills/agent-skill-kit-commons/scripts/parity-registry.sh
	bash .agents/skills/agent-skill-kit-commons/scripts/parity-lint.sh
	bash .agents/skills/agent-skill-kit-commons/scripts/parity-prompt.sh
	bash .agents/skills/agent-skill-kit-commons/scripts/parity-read-properties.sh
	bash .agents/skills/agent-skill-kit-commons/scripts/parity-optimize.sh
	bash .agents/skills/agent-skill-kit-commons/scripts/parity-parser-naming.sh

.PHONY: validate-suite
validate-suite: ## Validate every skill under .agents/skills/
	node .agents/skills/agent-skill-kit-commons/packages/mjs/bin/skills-ref validate .agents/skills/ --extra-tiers company,enterprise,application

.PHONY: audit-suite
audit-suite: ## Run security auditor over .agents/skills/
	node .agents/skills/agent-skill-kit-commons/packages/mjs/bin/skills-ref audit .agents/skills/

.PHONY: deps-suite
deps-suite: ## Resolve dependency graph for .agents/skills/
	node .agents/skills/agent-skill-kit-commons/packages/mjs/bin/skills-ref deps .agents/skills/

.PHONY: lint-suite
lint-suite: ## Run discoverability linter over .agents/skills/
	node .agents/skills/agent-skill-kit-commons/packages/mjs/bin/skills-ref lint .agents/skills/

.PHONY: prompt-suite
prompt-suite: ## Emit <available_skills> XML for .agents/skills/
	node .agents/skills/agent-skill-kit-commons/packages/mjs/bin/skills-ref to-prompt .agents/skills/

.PHONY: properties-suite
properties-suite: ## Emit canonical-JSON frontmatter for .agents/skills/
	node .agents/skills/agent-skill-kit-commons/packages/mjs/bin/skills-ref read-properties --root .agents/skills/

.PHONY: clean
clean: ## Clean per-package artifacts
	$(MAKE) -C .agents/skills/agent-skill-kit-commons/packages/mjs clean
	$(MAKE) -C .agents/skills/agent-skill-kit-commons/packages/py clean
