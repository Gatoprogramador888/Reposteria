namespace Reposteria.Models
{
    public class LogEvento
    {
        public int Id { get; set; }
        public string Evento { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
        public int PostresActualizados { get; set; } = 0;
        public DateTime FechaEjecucion { get; set; } = DateTime.Now;
    }
}