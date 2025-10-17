module tienda_mascotas::tienda {
    use std::string;
    use std::string::String;
    use sui::vec_map::{Self, VecMap};

    const CLAVE_YA_EXISTE: u64 = 1;
    const CLAVE_NO_EXISTE: u64 = 2;
    const PERMISO_DENEGADO: u64 = 3;

    /// Estructura principal de la tienda
    public struct TiendaMascotas has key, store {
        id: UID,
        nombre: String,
        inventario: VecMap<String, Mascota>,
        owner: address, // dueño de la tienda
    }

    /// Estructura de mascota
    public struct Mascota has copy, drop, store {
        nombre: String,
        especie: String,
        edad: u8,
        disponible: bool,
    }

    /// Crea una tienda en memoria
    public fun crear_tienda(ctx: &mut TxContext, nombre: String): TiendaMascotas {
        let inventario = vec_map::empty<String, Mascota>();
        let id = object::new(ctx);
        TiendaMascotas {
            id,
            nombre,
            inventario,
            owner: tx_context::sender(ctx),
        }
    }

    /// Registra la tienda y la transfiere al creador
    public fun registrar_tienda(nombre: String, ctx: &mut TxContext) {
        let tienda = crear_tienda(ctx, nombre);
        transfer::transfer(tienda, tx_context::sender(ctx));
    }

    /// Verifica que el sender sea dueño de la tienda
    fun validar_owner(tienda: &TiendaMascotas, ctx: &TxContext) {
        assert!(tx_context::sender(ctx) == tienda.owner, PERMISO_DENEGADO);
    }

    /// Agrega una nueva mascota a la tienda
    public fun agregar_mascota(
        tienda: &mut TiendaMascotas,
        id_mascota: String,
        nombre: String,
        especie: String,
        edad: u8,
        disponible: bool,
        ctx: &TxContext
    ) {
        validar_owner(tienda, ctx);
        assert!(!tienda.inventario.contains(&id_mascota), CLAVE_YA_EXISTE);
        let nueva_mascota = Mascota { nombre, especie, edad, disponible };
        tienda.inventario.insert(id_mascota, nueva_mascota);
    }

    /// Actualiza la disponibilidad de una mascota
    public fun actualizar_disponibilidad(
        tienda: &mut TiendaMascotas,
        id_mascota: String,
        disponible: bool,
        ctx: &TxContext
    ) {
        validar_owner(tienda, ctx);
        assert!(tienda.inventario.contains(&id_mascota), CLAVE_NO_EXISTE);
        let mascota_ref = tienda.inventario.get_mut(&id_mascota);
        mascota_ref.disponible = disponible;
    }

    /// Elimina una mascota de la tienda
    public fun eliminar_mascota(
        tienda: &mut TiendaMascotas,
        id_mascota: String,
        ctx: &TxContext
    ) {
        validar_owner(tienda, ctx);
        assert!(tienda.inventario.contains(&id_mascota), CLAVE_NO_EXISTE);
        tienda.inventario.remove(&id_mascota);
    }

    /// Obtiene los datos de una mascota
    public fun obtener_mascota(
        tienda: &TiendaMascotas,
        id_mascota: String
    ): Mascota {
        assert!(tienda.inventario.contains(&id_mascota), CLAVE_NO_EXISTE);
        *tienda.inventario.get(&id_mascota)
    }
}