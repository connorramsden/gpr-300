
#include <string>
class Shader
{
public:

	void loadShader();
private:
	string m_ShaderTitle;
	a3_DemoStateShader m_VertexShader;
	object m_FragmentShader;
};