## Рабочий процесс

2 машины:

- ==dev== - машина разработчика
- ==target== - целевая машина

Чтобы не задавать ip-адреса в скриптах, пропишем домены в файле /etc/hosts.

На ==dev==:

```
127.0.0.1     dev
__IP__        target
```

На ==target==:

```
127.0.0.1     target
```

Порядок работы:

- образы собираются на машине ==dev== и сохраняются в репозитории на этой же машине. Образы собираются с тегом `dev:5000`.
- (опционально) образы можно сохранить в файлы tar или загрузить из tar
- добавляем к образам тег - вместо `dev:5000` заменяем `target:5000`
- перемещаем образы на машину ==target==.

## Запуск локального репозитория образов ==dev==

Развернем локальный репозиторий образов вместе с веб-интерфейсом.

### Установка

Клонируем репозиторий:

```sh
cd ~/snap \
	&& git clone https://github.com/Joxit/docker-registry-ui.git
```

Настроим веб-интерфейс для работы через порт 8000.

- в файле `nano ~/snap/docker-registry-ui/examples/ui-as-standalone/registry-config/simple.yml` поменять заголовок:

```yml
Access-Control-Allow-Origin: ['*']
```

- поменять порт для сервиса `ui` в файле `nano ~/snap/docker-registry-ui/examples/ui-as-standalone/simple.yml`

```yml
ports:
	8000:80
```

### Запуск

Запускать командой:

```sh
cd ~/snap/docker-registry-ui/examples/ui-as-standalone \
	&& docker compose -f simple.yml up -d
```

- Репозиторий образов доступен по адресу: http://localhost:5000

- Веб-интерфейс доступен по адресу: http://localhost:8000

## Создание билдера buildx

Локальный репозиторий образов, для простоты, работает по протоколу http. Чтобы билдер смог загрузить образы, необходимо задать конфигурацию (выполнить в терминале одной строкой):

```sh
test -f ~/.buildkitd.toml || echo \
'[registry."dev:5000"]
http = true
insecure = true' \
> ~/.buildkitd.toml
```

Создать билдер можно командой:

```sh
docker buildx rm builder \
; docker run --rm --privileged multiarch/qemu-user-static --reset -p yes \
&& docker buildx create --name builder --driver docker-container --use --driver-opt network=host --config ~/.buildkitd.toml \
&& docker buildx inspect --bootstrap
```

## Сборка образов

Сборка образов описывается в файле `docker-bake.hcl`.

Запуск сборки:

```sh
docker buildx bake --builder builder -f docker-bake.hcl --push service_group 
```

## Перемещение образов из локального репозитория на целевую машину





- Сохранение образов из локального репозитория в tar-файлы.
- Загрузка образов из tar-файла в локальный репозиторий
- Перемещение образов из локального репозитория в удаленный