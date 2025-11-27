namespace Reposteria.DB
{
    public static class SQLConfig
    {
        public static string Usuario { get; } = "root";
        public static string Contrasena { get; } = "";
        public static string NomreBaseDatos { get; } = "reposteria";
        public static string Host { get; } = "localhost";
        public static int Puerto { get; } = 3306;

        public static string ObtenerConnectionString()
        {
            return $"Server={Host};Port={Puerto};Database={NomreBaseDatos};Uid={Usuario};Pwd={Contrasena};";
        }
    }
}