module tienda_mascotas::tienda {
    // Importamos String para texto y VecMap para mapa clave-valor
    use std::string::String;
    use sui::vec_map::{Self, VecMap};

    // Código de error para claves duplicadas o no encontradas
    const CLAVE_YA_EXISTE: u64 = 1;
    const CLAVE_NO_EXISTE: u64 = 2;

    // Estructura principal 'Mascotas' que tendrá la tienda y su inventario
    public struct Mascotas has key, store {
        id: UID,
        nombre_tienda: String,
        tienda: VecMap<String, Mascota>,
    }

    // Estructura para definir una mascota
    public struct Mascota has copy, drop, store {
        nombre: String,
        especie: String,
        edad: u8,
        disponible: bool,
    }

    // Función para crear la tienda de mascotas
    public fun crear_tienda(ctx: &mut TxContext, nombre: String) {
        let inventario = vec_map::empty<String, Mascota>();

        let nueva_tienda = Mascotas {
            id: object::new(ctx),
            nombre_tienda: nombre,
            tienda: inventario,
        };
        transfer::transfer(nueva_tienda, tx_context::sender(ctx));
    }

    // Función para agregar una mascota
    public fun agregar_mascota(mascotas: &mut Mascotas, clave: String, nombre: String, especie: String, edad: u8, disponible: bool) {
        assert!(!mascotas.tienda.contains(&clave), CLAVE_YA_EXISTE);
        let nueva_mascota = Mascota {
            nombre,
            especie,
            edad,
            disponible,
        };
        mascotas.tienda.insert(clave, nueva_mascota);
    }

    // Función para actualizar la disponibilidad de una mascota
    public fun actualizar_disponibilidad(mascotas: &mut Mascotas, clave: String, disponible: bool) {
        assert!(mascotas.tienda.contains(&clave), CLAVE_NO_EXISTE);
        let mascota_ref = &mut mascotas.tienda.get_mut(&clave).disponible;
        *mascota_ref = disponible;
    }

    // Función para eliminar una mascota del inventario
    public fun eliminar_mascota(mascotas: &mut Mascotas, clave: String) {
        assert!(mascotas.tienda.contains(&clave), CLAVE_NO_EXISTE);
        mascotas.tienda.remove(&clave);
    }
}