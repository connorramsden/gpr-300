//#include <string>
// class Shader
// {
// public:
// 
// 	void loadShader();
// private:
// 	string m_ShaderTitle;
// 	a3_DemoStateShader m_VertexShader;
// 	object m_FragmentShader;
// };

// 'Class' in C
typedef struct {
	char* m_ShaderTitle; // 'string' in c
	a3_DemoStateShader m_VertexShader;
} Shader;

void loadShader();