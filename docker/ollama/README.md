# Ollama Compose deployment

The maintained Compose template is `roles/ollama/templates/compose.yml.j2`. Ollama is disabled by default, stores models under `/srv/data/ollama`, and binds the API only to `127.0.0.1:11434`. This host has 3.2 GiB RAM and integrated graphics. Review available resources and approve a model before enabling or downloading anything.
