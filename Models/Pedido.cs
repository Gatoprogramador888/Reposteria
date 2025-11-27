namespace Reposteria.Models
{
    public class Pedido
    {
        public int Id { get; set; }
        public string NombreCliente { get; set; } = string.Empty;
        public DateTime DiaPedido { get; set; } = DateTime.Now;
        public bool Entregado { get; set; } = false;
        public decimal CostoTotal { get; set; }
        public string NumeroTelefonico { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string pedido { get; set; } = string.Empty;
        public int? ClienteFrecuenteId { get; set; }

        public ClienteFrecuente? ClienteFrecuente { get; set; }
    }
}