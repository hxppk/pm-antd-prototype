# 脚手架模板文件

阶段一初始化全新项目时，使用以下模板替换 Vite 默认文件。

## src/main.tsx

~~~tsx
import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import App from "./App";

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>
);
~~~

## src/App.tsx

~~~tsx
import { ConfigProvider } from "antd";
import zhCN from "antd/locale/zh_CN";
import { useRoutes } from "react-router-dom";
import BasicLayout from "./layouts/BasicLayout";

const routes = [
  {
    path: "/",
    element: <BasicLayout />,
    children: [
      // 页面路由将在代码生成时自动追加到这里
    ],
  },
];

export default function App() {
  const element = useRoutes(routes);
  return <ConfigProvider locale={zhCN}>{element}</ConfigProvider>;
}
~~~

## src/layouts/BasicLayout.tsx

~~~tsx
import { Layout, Menu } from "antd";
import { Outlet } from "react-router-dom";

const { Header, Sider, Content } = Layout;

export default function BasicLayout() {
  return (
    <Layout style={{ minHeight: "100vh" }}>
      <Header>
        <Menu
          theme="dark"
          mode="horizontal"
          items={[
            // 导航菜单项将在代码生成时自动追加
          ]}
        />
      </Header>
      <Layout>
        <Sider width={200}>
          <Menu
            mode="inline"
            style={{ height: "100%" }}
            items={[
              // 侧边栏菜单项将在代码生成时自动追加
            ]}
          />
        </Sider>
        <Content style={{ padding: 24 }}>
          <Outlet />
        </Content>
      </Layout>
    </Layout>
  );
}
~~~

