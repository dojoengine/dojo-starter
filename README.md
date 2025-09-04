En core ya tuve que haber ejecutado los comandos make katana y make setup.

Ahora vamos a hacer deploy de profile con el comando make setup.

De los logs de profile copiar el address del profile_system

jokers_of_neon_profile-profile_system - 0x02ff6dcdc9f8bcc89183b33e14d9739d871187626b48dc18ebaebe8ef81f22b5

Revisar en los logs por si cambio

Ahora ejecutar en core el siguiente comando 

sozo execute profile_manager register_address_profile \
    $profile_address \
    --wait \
    --world $world_address

Por ejemplo: 

sozo execute profile_manager register_address_profile \
    0x02ff6dcdc9f8bcc89183b33e14d9739d871187626b48dc18ebaebe8ef81f22b5 \
    --wait \
    --world 0x5d151da3085badd054db02d2c0891dcdc6a98538ea0e86edea0e45ea70df72d
