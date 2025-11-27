namespace Reposteria.Models
{
    public class Postre
    {
        public int Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public decimal Precio { get; set; }
        public string NombreImg { get; set; } = string.Empty;
        public DateTime Creacion { get; set; } = DateTime.Now;
        public bool Nuevo { get; set; } = true;
    }
}