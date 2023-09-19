docker tag llama-7b-api neullmstudio.azurecr.io/llm/llama-7b-ggml-api
docker push neullmstudio.azurecr.io/llm/llama-7b-ggml-api
### In case if authentication required error message #####
az acr login --name neullmstudio
docker pull neullmstudio.azurecr.io/llm/llama-7b-ggml-api