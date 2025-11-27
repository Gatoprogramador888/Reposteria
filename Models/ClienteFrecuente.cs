namespace Reposteria.Models
{
    public class ClienteFrecuente
    {
        public int Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string NumeroTelefonico { get; set; } = string.Empty;
        public decimal Descuento { get; set; } = 0.00m;
        public string Email { get; set; } = string.Empty;
        public DateTime FechaRegistro { get; set; } = DateTime.Now;

        public ICollection<Pedido> Pedidos { get; set; } = new List<Pedido>();
    }
}