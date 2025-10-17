module tienda_mascotas::tienda {
    use std::string;
    use std::string::String;
    use sui::vec_map::{Self, VecMap};
    use sui::object;
    use sui::transfer;
    use sui::tx_context::TxContext;

    const CLAVE_YA_EXISTE: u64 = 1;
    const CLAVE_NO_EXISTE: u64 = 2;

    public struct Mascotas has key, store {
        id: UID,
        nombre_tienda: String,
        tienda: VecMap<String, Mascota>,
    }

    public struct Mascota has copy, drop, store {
        nombre: String,
        especie: String,
        edad: u8,
        disponible: bool,
    }

    public fun crear_tienda(ctx: &mut TxContext, nombre: String): Mascotas {
        let inventario = vec_map::empty<String, Mascota>();
        let id = object::new(ctx);
        Mascotas {
            id,
            nombre_tienda: nombre,
            tienda: inventario,
        }
    }

    public fun agregar_mascota(mascotas: &mut Mascotas, clave: String, nombre: String, especie: String, edad: u8, disponible: bool) {
        assert!(!mascotas.tienda.contains(&clave), CLAVE_YA_EXISTE);
        let nueva_mascota = Mascota { nombre, especie, edad, disponible };
        mascotas.tienda.insert(clave, nueva_mascota);
    }

    public fun actualizar_disponibilidad(mascotas: &mut Mascotas, clave: String, disponible: bool) {
        assert!(mascotas.tienda.contains(&clave), CLAVE_NO_EXISTE);
        let mascota_ref = &mut mascotas.tienda.get_mut(&clave).disponible;
        *mascota_ref = disponible;
    }

    public fun eliminar_mascota(mascotas: &mut Mascotas, clave: String) {
        assert!(mascotas.tienda.contains(&clave), CLAVE_NO_EXISTE);
        mascotas.tienda.remove(&clave);
    }

    public fun obtener_mascota(mascotas: &Mascotas, clave: String): Mascota {
        assert!(mascotas.tienda.contains(&clave), CLAVE_NO_EXISTE);
        *mascotas.tienda.get(&clave)
    }

    #[test]
    public fun test_tienda_mascotas(ctx: &mut TxContext) {
        // Crear la tienda
        let mut tienda_obj = crear_tienda(ctx, string::utf8(b"Tienda Dev"));

        // Agregar mascotas
        agregar_mascota(&mut tienda_obj, string::utf8(b"mascota1"), string::utf8(b"Firulais"), string::utf8(b"Perro"), 3, true);
        agregar_mascota(&mut tienda_obj, string::utf8(b"mascota2"), string::utf8(b"Misu"), string::utf8(b"Gato"), 2, true);

        // Verificar que mascota1 existe y es disponible
        let mascota1 = obtener_mascota(&tienda_obj, string::utf8(b"mascota1"));
        assert!(mascota1.disponible, 100);
        assert!(mascota1.nombre == string::utf8(b"Firulais"), 101);
        assert!(mascota1.especie == string::utf8(b"Perro"), 102);
        assert!(mascota1.edad == 3, 103);

        // Actualizar disponibilidad de mascota1 a false
        actualizar_disponibilidad(&mut tienda_obj, string::utf8(b"mascota1"), false);
        let mascota1_actualizada = obtener_mascota(&tienda_obj, string::utf8(b"mascota1"));
        assert!(!mascota1_actualizada.disponible, 104);

        // Eliminar mascota2
        eliminar_mascota(&mut tienda_obj, string::utf8(b"mascota2"));
        assert!(!tienda_obj.tienda.contains(&string::utf8(b"mascota2")), 105);
    }
}