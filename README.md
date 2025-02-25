# Dockerfile образа 1C EDT

Образ предназначен для сборки конфигураций и внешних обработок 1С.

## Предварительные требования

- make

- Docker

- дистрибутив Технологическая платформа 1С:Предприятия (64-bit) для Linux

- дистрибутив 1C:EDT для ОС Linux для установки без интернета


## Сборка

Для сборки образа рядом с Dockerfile необходимо разместить архивы с платформой (файл должен иметь имя 1cplatform.zip) и EDT (имя файла - 1cedt.tar.gz).

- Для сборки образа с платформой 1С выполнить команду
    ```shell
    # Здесь X и Y заменить на конкретную версию устанавливаемой платформы, например 8.3.24.1808
    make 1c-image PLATFORM_VERSION=8.3.X.Y 
    ```

- Для сборки образа с EDT выполнить команду
     ```shell
    # Здесь X.Y.Z+A заменить на конкретную версию устанавливаемой EDT и ее сборку, например EDT_VERSION=2024.1.3+13
    make edt-image EDT_VERSION=X.Y.Z+A
    ```

## Использование в пайплайнах

```yaml
# Пример .gitlab-ci.yml

default:
    variables:
        EDT_VERSION: 2024.1.3-13
        EDT_VMARGS: -Xmx3g
        V8_PLATFORM_VERSION: 8.3.24.1761

# Экспорт проекта EDT в XML файлы конфигурации
export-edt-project:
    stage: build
    image: 
        name: 1c-edt:${EDT_VERSION}
    script:
        - mkdir ${CI_PROJECT_DIR}/{ws,cfg-files}
        - 1cedtcli -data ${CI_PROJECT_DIR}/ws -v -vmargs %{EDT_VMARGS} -command export --project ${CI_PROJECT_DIR}/ИмяПроекта --configuration-files ${CI_PROJECT_DIR}/cfg-files
    artifacts:
        paths: 
          - cfg-files/

# Сборка файла конфигурации из XML файлов
build-cf:
    stage: build
    dependencies:
        - export-edt-project
    image:
        name: 1c-platform:${V8_PLATFORM_VERSION}
    variables:
        V8_IB_PATH: ${CI_PROJECT_DIR}/ib
        V8_CMD_OPTIONS: '/WA- /DisableStartupDialogs /DisableSplash /UseHwLicenses+ /Out /dev/stdout'
    before_script:
        - Xvfb &
        - export DISPLAY=:0
    script:
        # Создание ИБ
        - 1cv8 CREATEINFOBASE File=${V8_IB_PATH} ${V8_CMD_OPTIONS}
        # Загрузка конфигурации из файлов XML
        - 1cv8 DESIGNER /IBConnectionString File=${V8_IB_PATH} /LoadConfigFromFiles ${CI_PROJECT_DIR}/cfg-files ${V8_CMD_OPTIONS} 
        # Выгрузка конфигурации в файл
        - 1cv8 DESIGNER /IBConnectionString File=${V8_IB_PATH} /DumpCfg ${CI_PROJECT_DIR}/1cv8.cf ${V8_CMD_OPTIONS} 
    artifacts:
        paths: 
          - 1cv8.cf

# Проверка конфигурации Конфигуратором
check-cf:
    stage: test
    dependencies:
        - build-cf
    image:
        name: 1c-platform:${V8_PLATFORM_VERSION}
    variables:
        V8_IB_PATH: ${CI_PROJECT_DIR}/ib
        V8_CMD_OPTIONS: '/WA- /DisableStartupDialogs /DisableSplash /UseHwLicenses+ /Out /dev/stdout'
    before_script:
        - Xvfb &
        - export DISPLAY=:0
    script:
        # Создание ИБ
        - 1cv8 CREATEINFOBASE File=${V8_IB_PATH} ${V8_CMD_OPTIONS}
        # Загрузка конфигурации из файлов XML
        - 1cv8 DESIGNER /IBConnectionString File=${V8_IB_PATH} /LoadCfg ${CI_PROJECT_DIR}/1cv8.cf ${V8_CMD_OPTIONS} 
        # Проверка конфигурации
        - 1cv8 DESIGNER /IBConnectionString File=${V8_IB_PATH} /CheckConfig -ConfigLogIntegrity -ThinClient -Server ${V8_CMD_OPTIONS} 
    artifacts:
        paths: 
          - 1cv8.cf

# Валидация проекта
validate-edt-project:
    stage: test
    image: 
        name: 1c-edt:${EDT_VERSION}
    script:
        - mkdir ${CI_PROJECT_DIR}/ws
        - 1cedtcli -data ${CI_PROJECT_DIR}/ws -v -vmargs %{EDT_VMARGS} -command validate --file validation-result.tsv --project-list ${CI_PROJECT_DIR}/ИмяПроекта
    artifacts:
        paths:
            - validation-result.tsv
    reports:
        codequality: validation-result.tsv
```

## Полезные ссылки

- [Исправление ошибок клиента 1С в Linux](https://interface31.ru/tech_it/2024/08/ispravlyaem-oshibki-zapuska-klienta-1spredpriyatie-v-sovremennyh-vypuskah-linux.html)

- [Параметры командной строки запуска](https://its.1c.ru/db/v8324doc#bookmark:adm:TI000000493)

- [Интерфейс командной строки 1C:EDT CLI](https://its.1c.ru/db/edtdoc#content:10608:hdoc)
