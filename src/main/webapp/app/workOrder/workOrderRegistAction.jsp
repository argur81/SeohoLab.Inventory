화면(JSP)에서 새롭게 추가되거나 변경된 데이터(예: 총 제조지시량, 이론제조량, 단가, 함량 등)를 폼으로 넘겨받아 데이터베이스에 안전하게 저장할 수 있도록 workOrderRegistAction.jsp 파일도 함께 수정해야 합니다.

새로운 컬럼들과 콤마(,)가 포함되어 넘어올 수 있는 숫자 값들을 정제(파싱)하여 처리하는 workOrderRegistAction.jsp 예시 코드입니다.

workOrderRegistAction.jsp
Java
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    // 한글 인코딩 설정
    request.setCharacterEncoding("UTF-8");

    // 1. 상단 마스터 정보 수신 (콤마 제거 및 형변환 처리)
    String productName = request.getParameter("product_name");
    
    String targetQtyStr = request.getParameter("target_qty");
    double targetQty = (targetQtyStr != null && !targetQtyStr.trim().isEmpty()) ? Double.parseDouble(targetQtyStr.replace(",", "")) : 0.0;
    String targetUnit = request.getParameter("target_unit");
    
    String managerName = request.getParameter("manager_name");
    String machine = request.getParameter("machine");
    String appearance = request.getParameter("appearance");
    String scent = request.getParameter("scent");
    String specificGravity = request.getParameter("specific_gravity");
    String ph = request.getParameter("ph");
    
    String theorQtyStr = request.getParameter("theor_qty");
    double theorQty = (theorQtyStr != null && !theorQtyStr.trim().isEmpty()) ? Double.parseDouble(theorQtyStr.replace(",", "")) : 0.0;
    String theorUnit = request.getParameter("theor_unit");
    
    String yieldRateStr = request.getParameter("yield_rate");
    double yieldRate = (yieldRateStr != null && !yieldRateStr.trim().isEmpty()) ? Double.parseDouble(yieldRateStr.replace(",", "")) : 0.0;
    
    String yieldStandard = request.getParameter("yield_standard");

    // 2. 하단 원료 상세 목록 배열 수신
    String[] rawMaterialNames = request.getParameterValues("raw_material_name");
    String[] testNumbers = request.getParameterValues("test_number");
    String[] contentPcts = request.getParameterValues("content_pct");
    String[] orderQtyKgs = request.getParameterValues("order_qty_kg");
    String[] orderQtyGs = request.getParameterValues("order_qty_g");
    String[] unitPrices = request.getParameterValues("unit_price");

    // 3. 제조 방법 및 상(Phase) 정보 배열 수신 (필요시 활용)
    String[] phaseTitles = request.getParameterValues("phase_title");
    String[] phaseStarts = request.getParameterValues("phase_start");
    String[] phaseEnds = request.getParameterValues("phase_end");
    String[] methodDescs = request.getParameterValues("method_desc");
    String[] noteDescs = request.getParameterValues("note_desc");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // TODO: 프로젝트 환경에 맞는 DB 커넥션 로직으로 변경해주세요.
        // 예: Class.forName("com.mysql.cj.jdbc.Driver");
        // conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/your_db", "user", "password");
        
        // 트랜잭션 시작
        conn.setAutoCommit(false);

        // [STEP 1] 제조 지시서 마스터(Master) 정보 저장 쿼리 예시
        String masterSql = "INSERT INTO work_order_master (product_name, target_qty, target_unit, manager_name, machine, appearance, scent, specific_gravity, ph, theor_qty, theor_unit, yield_rate, yield_standard, reg_date) " +
                           "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
        
        // 만약 마스터 저장 후 생성된 PK(ID)를 디테일 테이블에 연동해야 한다면 Statement.RETURN_GENERATED_KEYS 옵션을 사용하세요.
        pstmt = conn.prepareStatement(masterSql, Statement.RETURN_GENERATED_KEYS);
        pstmt.setString(1, productName);
        pstmt.setDouble(2, targetQty);
        pstmt.setString(3, targetUnit);
        pstmt.setString(4, managerName);
        pstmt.setString(5, machine);
        pstmt.setString(6, appearance);
        pstmt.setString(7, scent);
        pstmt.setString(8, specificGravity);
        pstmt.setString(9, ph);
        pstmt.setDouble(10, theorQty);
        pstmt.setString(11, theorUnit);
        pstmt.setDouble(12, yieldRate);
        pstmt.setString(13, yieldStandard);
        
        pstmt.executeUpdate();

        // 생성된 마스터 ID 가져오기 (디테일 테이블 외래키 연결용)
        int masterId = 0;
        rs = pstmt.getGeneratedKeys();
        if (rs.next()) {
            masterId = rs.getInt(1);
        }
        pstmt.close();

        // [STEP 2] 원료 상세(Detail) 정보 반복문 저장 쿼리 예시
        if (rawMaterialNames != null) {
            String detailSql = "INSERT INTO work_order_detail (master_id, row_seq, raw_material_name, test_number, content_pct, order_qty_kg, order_qty_g, unit_price) " +
                               "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(detailSql);

            for (int i = 0; i < rawMaterialNames.length; i++) {
                // 빈 행은 건너뛰기
                if (rawMaterialNames[i] == null || rawMaterialNames[i].trim().isEmpty()) continue;

                double contentPct = (contentPcts != null && contentPcts[i] != null && !contentPcts[i].isEmpty()) ? Double.parseDouble(contentPcts[i].replace(",", "")) : 0.0;
                double orderKg = (orderQtyKgs != null && orderQtyKgs[i] != null && !orderQtyKgs[i].isEmpty()) ? Double.parseDouble(orderQtyKgs[i].replace(",", "")) : 0.0;
                double orderG = (orderQtyGs != null && orderQtyGs[i] != null && !orderQtyGs[i].isEmpty()) ? Double.parseDouble(orderQtyGs[i].replace(",", "")) : 0.0;
                double unitPrice = (unitPrices != null && unitPrices[i] != null && !unitPrices[i].isEmpty()) ? Double.parseDouble(unitPrices[i].replace(",", "")) : 0.0;

                pstmt.setInt(1, masterId);
                pstmt.setInt(2, i + 1); // No. 순번
                pstmt.setString(3, rawMaterialNames[i]);
                pstmt.setString(4, testNumbers != null ? testNumbers[i] : "");
                pstmt.setDouble(5, contentPct);
                pstmt.setDouble(6, orderKg);
                pstmt.setDouble(7, orderG);
                pstmt.setDouble(8, unitPrice);
                
                pstmt.addBatch();
            }
            pstmt.executeBatch();
            pstmt.close();
        }

        // [STEP 3] 제조 방법 및 상(Phase) 정보 저장 쿼리 예시 (필요시 활성화)
        /*
        if (phaseTitles != null) {
            String phaseSql = "INSERT INTO work_order_phase (master_id, phase_title, phase_start, phase_end, method_desc, note_desc) VALUES (?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(phaseSql);

            for (int i = 0; i < phaseTitles.length; i++) {
                pstmt.setInt(1, masterId);
                pstmt.setString(2, phaseTitles[i]);
                pstmt.setInt(3, Integer.parseInt(phaseStarts[i]));
                pstmt.setInt(4, Integer.parseInt(phaseEnds[i]));
                pstmt.setString(5, methodDescs != null ? methodDescs[i] : "");
                pstmt.setString(6, noteDescs != null ? noteDescs[i] : "");
                
                pstmt.addBatch();
            }
            pstmt.executeBatch();
            pstmt.close();
        }
        */

        // 모든 작업 성공 시 커밋
        conn.commit();
        
        out.println("<script>alert('제조 지시서가 성공적으로 등록되었습니다.'); location.href='workOrderList.jsp';</script>");

    } catch (Exception e) {
        // 오류 발생 시 롤백
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException ex) { /* ignored */ }
        }
        e.printStackTrace();
        out.println("<script>alert('등록 중 오류가 발생했습니다: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>