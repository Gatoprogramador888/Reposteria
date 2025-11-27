using Microsoft.EntityFrameworkCore;
using Reposteria.DB;
using Reposteria.Models;

namespace Reposteria.Querys.Repositorio
{
    public class RepositorioPedido : RepositorioGenerico<Pedido>
    {
        public RepositorioPedido(AppDbContext context) : base(context)
        {
        }

        // Método personalizado: obtener pedidos entregados
        public async Task<List<Pedido>> ObtenerPedidosEntregados()
        {
            return await EjecutarSQLPuro("SELECT * FROM pedido WHERE entregado = 1");
        }

        // Método personalizado: obtener pedidos por cliente frecuente (SQL puro)
        public async Task<List<Pedido>> ObtenerPedidosPorClienteFrecuente(int clienteFrecuenteId)
        {
            string sql = $"SELECT * FROM pedido WHERE cliente_frecuente_id = {clienteFrecuenteId}";
            return await EjecutarSQLPuro(sql);
        }

        // Método personalizado: obtener pedidos con información de cliente frecuente (vista)
        public async Task<dynamic> ObtenerPedidosCompletos()
        {
            string sql = "SELECT * FROM v_pedidos_completos";
            return await _context.Database.ExecuteSqlRawAsync(sql);
        }

        // Método personalizado: actualizar estado de entrega
        public async Task<int> ActualizarEstadoEntrega(int pedidoId, bool entregado)
        {
            string sql = $"UPDATE pedido SET entregado = {(entregado ? 1 : 0)} WHERE id = {pedidoId}";
            return await EjecutarSQL(sql);
        }
    }
}