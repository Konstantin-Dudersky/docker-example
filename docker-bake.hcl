/*
Запустить сборку и загрузку образов:

docker buildx bake --builder builder -f docker-bake.hcl --push service_group
*/

variable "PYTHON_VER" { default = "3.11.0" }
variable "POETRY_VER" { default = "1.2.2" }

REPO = "dev:5000"

target "webapp" {
    dockerfile = "webapp/Dockerfile"
    tags = [ "${REPO}/docker-example/webapp" ]
    platforms = [
        "linux/amd64",
    ]
}

# базовый образ для сервисов python
target "base_image" {
    dockerfile = "shared/Dockerfile"
    args = {
        POETRY_VER = "${POETRY_VER}",
        PYTHON_VER = "${PYTHON_VER}",
    }
    platforms = [
        "linux/amd64",
    ]
}


target "python_service" {
    contexts = {
        base_image = "target:base_image"
    }
    dockerfile = "python_service/Dockerfile"
    tags = [ "${REPO}/docker-example/python_service" ]
    platforms = [ 
        "linux/amd64",
    ]
}


group "service_group" {
    targets = [
        "python_service",
    ]
}
