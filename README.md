# Dockerfile образа 1C EDT

Образ предназначен для сборки конфигураций и внешних обработок 1С.

## Сборка

Для сборки образа рядом с Dockerfile необходимо разместить архивы с платформой и EDT, имена которых будут соответствовать шаблону:
* Для EDT - `1c_edt_distr_offline_[EDT_RELEASE]+[EDT_BUILD]_linux_x86_64.tar.gz`
* Для платформы - `server64_[E1C_VERSION_MAJOR]_[E1C_VERSION_MINOR]_[E1C_VERSION_BUILD]_[E1C_VERSION_PATCH].tar.gz`

> Например, необходимо собрать образ с платформой 1С:Предприятие версии 8.3.23.2157 и EDT 2023.3.5+10.
> В данном случае `E1C_VERSION_MAJOR` = 8, `E1C_VERSION_MINOR` = 3, `E1C_VERSION_BUILD` = 23, `E1C_VERSION_PATCH` = 2157, `EDT_RELEASE` = 2023.3.5, `EDT_BUILD` = 10.
> Для сборки скачиваем с портала 1С дистрибутивы и размещаем в директории следующие файлы:
> * *1c_edt_distr_offline_2023.3.5_10_linux_x86_64.tar.gz* - дистрибутив платформы
> * *server64_8_3_23_2157.tar.gz* - дистрибутив EDT
>
> После выполняем команду:
> ```shell
>docker build \
>   --build-arg E1C_VERSION_BUILD=23 \
>   --build-arg E1C_VERSION_PATCH=2157 \
>   --build-arg EDT_RELEASE=2023.3.5\
>   --build-arg EDT_BUILD=10 \
>   .
>```

## Аргументы сборки

`E1C_VERSION_MAJOR` - Мажорная версия платформы (по умолчанию 8)

`E1C_VERSION_MINOR` - Минорная версия платформы (по умолчанию 3)

`E1C_VERSION_BUILD` - Номер сборки платформы (по умолчанию 23)

`E1C_VERSION_PATCH`- Номер патча (по умолчанию 2157)

`EDT_RELEASE` - Версия EDT (по умолчанию 2023.3.5)

`EDT_BUILD` - Номер сборки EDT (по умолчанию 10)