using UnityEngine;

namespace SpookyRiver
{
    public class Turbulant: MonoBehaviour
    {
        public float x_wavelength;
        public float z_wavelength;
        public float wave_amplitude;
        public float wave_speed;

        /// Make sure to assign the mesh!
        public MeshFilter meshFilter;
        public void Update()
        {

        if (meshFilter == null) return;
        
            Vector3[] water_verts = meshFilter.mesh.vertices;
            var x_omega = (x_wavelength == 0) ? 0 : 1/x_wavelength;
            var z_omega = (z_wavelength == 0) ? 0 : 1/z_wavelength;

            for (int i=0; i<water_verts.Length; i++){
                water_verts[i].y = wave_amplitude
                    * Mathf.Sin(
                    x_omega * water_verts[i].x
                    + z_omega * water_verts[i].z
                    + wave_speed * Time.time);
            }
            meshFilter.mesh.vertices = (water_verts); 
        }
    }
}