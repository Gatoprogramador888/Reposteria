using Microsoft.EntityFrameworkCore;
using Reposteria.DB;
using System.Data;

namespace Reposteria.Querys.Repositorio
{
    public class RepositorioGenerico<T> where T : class
    {
        protected readonly AppDbContext _context;
        protected readonly DbSet<T> _dbSet;

        public RepositorioGenerico(AppDbContext context)
        {
            _context = context;
            _dbSet = context.Set<T>();
        }

        // Operaciones básicas CRUD con LINQ
        public async Task<List<T>> ObtenerTodos()
        {
            return await _dbSet.ToListAsync();
        }

        public async Task<T?> ObtenerPorId(int id)
        {
            return await _dbSet.FindAsync(id);
        }

        public async Task<T> Crear(T entidad)
        {
            await _dbSet.AddAsync(entidad);
            await _context.SaveChangesAsync();
            return entidad;
        }

        public async Task<T> Actualizar(T entidad)
        {
            _dbSet.Update(entidad);
            await _context.SaveChangesAsync();
            return entidad;
        }

        public async Task<bool> Eliminar(int id)
        {
            var entidad = await _dbSet.FindAsync(id);
            if (entidad == null) return false;

            _dbSet.Remove(entidad);
            await _context.SaveChangesAsync();
            return true;
        }

        // Ejecutar SQL puro para consultas complejas o por rendimiento
        public async Task<List<T>> EjecutarSQLPuro(string sql)
        {
            return await _dbSet.FromSqlRaw(sql).ToListAsync();
        }

        // Ejecutar SQL puro con parámetros
        public async Task<List<T>> EjecutarSQLPuroConParametros(string sql, params object[] parametros)
        {
            return await _dbSet.FromSqlInterpolated($"{sql}").ToListAsync();
        }

        // Ejecutar procedimiento almacenado
        public async Task<List<T>> EjecutarProcedimiento(string nombreProcedimiento, params object[] parametros)
        {
            return await _dbSet.FromSqlRaw($"CALL {nombreProcedimiento}", parametros).ToListAsync();
        }

        // Ejecutar SQL puro sin mapeo de modelo (para inserciones, actualizaciones, eliminaciones directas)
        public async Task<int> EjecutarSQL(string sql)
        {
            return await _context.Database.ExecuteSqlRawAsync(sql);
        }

        // Ejecutar SQL puro con parámetros sin mapeo
        public async Task<int> EjecutarSQLConParametros(string sql, params object[] parametros)
        {
            return await _context.Database.ExecuteSqlRawAsync(sql, parametros);
        }
    }
}