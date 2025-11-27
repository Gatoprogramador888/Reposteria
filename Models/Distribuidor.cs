namespace Reposteria.Models
{
    public class Distribuidor
    {
        public int Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string NumeroTelefonico { get; set; } = string.Empty;
        public string Producto { get; set; } = string.Empty;
        public decimal? Precio { get; set; }
        public string Email { get; set; } = string.Empty;
    }
}