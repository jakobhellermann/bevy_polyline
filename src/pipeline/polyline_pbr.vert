#version 450

layout(location = 0) in vec3 I_Point0;
layout(location = 1) in vec3 I_Point1;

layout(location = 0) out vec3 v_WorldPosition;
layout(location = 1) out vec3 v_WorldNormal;
layout(location = 2) out vec2 v_Uv;

layout(set = 0, binding = 0) uniform CameraViewProj {
    mat4 ViewProj;
};

#ifdef STANDARDMATERIAL_NORMAL_MAP
layout(location = 3) out vec4 v_WorldTangent;
#endif

layout(set = 2, binding = 0) uniform Transform {
    mat4 Model;
};

layout(set = 1, binding = 1) uniform GlobalResources_resolution {
    vec2 resolution;
};

layout(set = 3, binding = 15) uniform PolylinePbrMaterial_width {
    float width;
};

mat3 matrix_dot(mat3 first, mat3 second) {
    return mat3(
        first[0][0] * second[0][0] + first[0][1] * second[1][0] + first[0][2] * second[2][0],
        first[0][0] * second[0][1] + first[0][1] * second[1][1] + first[0][2] * second[2][1],
        first[0][0] * second[0][2] + first[0][1] * second[1][2] + first[0][2] * second[2][2],

        first[1][0] * second[0][0] + first[1][1] * second[1][0] + first[1][2] * second[2][0],
        first[1][0] * second[0][1] + first[1][1] * second[1][1] + first[1][2] * second[2][1],
        first[1][0] * second[0][2] + first[1][1] * second[1][2] + first[1][2] * second[2][2],

        first[2][0] * second[0][0] + first[2][1] * second[1][0] + first[2][2] * second[2][0],
        first[2][0] * second[0][1] + first[2][1] * second[1][1] + first[2][2] * second[2][1],
        first[2][0] * second[0][2] + first[2][1] * second[1][2] + first[2][2] * second[2][2]);
}

void main() {
    vec3[] vertices = {
        { -0.5, 0.0, 0.0 },
        { -0.5, 1.0, 0.0 },
        { 0.5, 1.0, 0.0 },
        { -0.5, 0.0, 0.0 },
        { 0.5, 1.0, 0.0 },
        { 0.5, 0.0, 0.0 }
    };

    vec3 vertex = vertices[gl_VertexIndex];

    vec3 point = mix(I_Point0, I_Point1, vertex.y);

    // from https://math.stackexchange.com/questions/180418/calculate-rotation-matrix-to-align-vector-a-to-vector-b-in-3d/
    // TODO handle direction == -up
    // TODO rotation incorrect when norm < 1???
    vec3 up = vec3(0.0, 1.0, 0.0);
    vec3 direction = I_Point1 - I_Point0;
    float norm = length(direction);
    direction = direction / norm;
    vec3 v = cross(up, direction);
    // float s = length(v);
    float c = dot(up, direction);
    mat3 identity = mat3(1, 0, 0, 0, 1, 0, 0, 0, 1);
    mat3 vx = mat3(0, v.z, -v.y, -v.z, 0, v.x, v.y, -v.x, 0);
    mat3 rotation = identity + vx + matrix_dot(vx, vx) * 1 / (1 + c);

    vertex.y *= norm;
    vec3 position = rotation * vertex + I_Point0;

    // mat4 new_view_proj = ViewProj;
    // new_view_proj[1] = vec4(0, 1, 0, 0);
    // vec4 final_position = new_view_proj * Model * vec4(position, 1.0);

    vec4 final_position = ViewProj * Model * vec4(position, 1.0);

    v_WorldPosition = vec3(0.0);
    v_WorldNormal = vec3(0.0);
    v_Uv = vec2(0.0);
    gl_Position = final_position;

    //         vec3[] positions = {
    //         { 0.0, -0.5, 0.0 },
    //         { 0.0, -0.5, 1.0 },
    //         { 0.0, 0.5, 1.0 },
    //         { 0.0, -0.5, 0.0 },
    //         { 0.0, 0.5, 1.0 },
    //         { 0.0, 0.5, 0.0 }
    //     };

    //     vec3 position = positions[gl_VertexIndex];

    //     // algorithm based on https://wwwtyro.net/2019/11/18/instanced-lines.html
    //     vec4 clip0 = ViewProj * Model * vec4(I_Point0, 1);
    //     vec4 clip1 = ViewProj * Model * vec4(I_Point1, 1);
    //     vec4 clip = mix(clip0, clip1, position.z);

    //     vec2 screen0 = resolution * (0.5 * clip0.xy / clip0.w + 0.5);
    //     vec2 screen1 = resolution * (0.5 * clip1.xy / clip1.w + 0.5);

    //     vec2 direction = normalize(screen1 - screen0);
    //     vec2 perpendicular = vec2(-direction.y, direction.x);

    // #ifdef POLYLINEPBRMATERIAL_PERSPECTIVE
    //     float width = width / clip.w;
    //     // Line thinness fade from https://acegikmo.com/shapes/docs/#anti-aliasing
    //     if (width < 1.0) {
    //         width = 1.0;
    //     }
    // #endif

    //     vec2 pt0 = screen0 + width * (position.x * direction + position.y * perpendicular);
    //     vec2 pt1 = screen1 + width * (position.x * direction + position.y * perpendicular);
    //     vec2 pt = mix(pt0, pt1, position.z);

    //     gl_Position = vec4(clip.w * ((2.0 * pt) / resolution - 1.0), clip.z, clip.w);

    //     v_WorldPosition = (inverse(ViewProj) * gl_Position).xyz;
    //     v_WorldNormal = inverse(mat3(ViewProj)) * cross(vec3(direction, clip.z), vec3(perpendicular, clip.z));
    //     v_Uv = vec2(position.x + 0.5, position.y);

    // vec3[] positions = {
    //     { -0.5, 0.0, 0.0 },
    //     { -0.5, 1.0, 0.0 },
    //     { 0.5, 1.0, 0.0 },
    //     { -0.5, 0.0, 0.0 },
    //     { 0.5, 1.0, 0.0 },
    //     { 0.5, 0.0, 0.0 }
    // };

    // vec3 position = positions[gl_VertexIndex];

    // // Pick right base point for this vertex
    // vec4 clip0 = ViewProj * Model * vec4(I_Point0, 1);
    // vec4 clip1 = ViewProj * Model * vec4(I_Point1, 1);
    // vec4 clip = mix(clip0, clip1, position.z);

    // vec3 direction = normalize(I_Point1 - I_Point0);
    // vec3 normal = vec3(0, 0, -1.0);
    // vec3 perpendicular = cross(direction, normal);
    // normal = cross(direction, perpendicular);

    // // mat4 transform = mat4(
    // //     perendicular.x, normal.x, -direction.x, I_Point0.x,
    // //     perendicular.y, normal.y, -direction.y, I_Point0.y,
    // //     perendicular.z, normal.z, -direction.z, I_Point0.z,
    // //     0.0, 0.0, 0.0, 1.0
    // // );

    // // float aspect = resolution.x / resolution.y;
    // // vec3 width = width * vec3(aspect, 1.0, 1.0);
    // vec3 point = mix(I_Point0, I_Point1, position.y);
    // point += perpendicular * width / clip.w * position.x;

    // v_WorldPosition = (Model * vec4(point, 1.0)).xyz;
    // v_WorldNormal = normal;
    // v_Uv = vec2(position.x + 0.5, position.y);

    // gl_Position = ViewProj * vec4(v_WorldPosition, 1.0);
}