namespace Reposteria.Models
{
    public class Administrador
    {
        public int Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Contrasena { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
    }
}